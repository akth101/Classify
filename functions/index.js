// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const {onCall} = require("firebase-functions/v2/https");
const {onRequest} = require("firebase-functions/v2/https");

// The Firebase Admin SDK to access Firestore.
const {initializeApp} = require("firebase-admin/app");

// Google Generative AI SDK for Gemini
const genai = require("@google/genai");

// Initialize Firebase Admin
initializeApp();

// 기본 오류 응답 생성 함수
const createErrorResponse = (errorMessage, memoText, memoCategories) => {
  return {
    error: errorMessage,
    category: memoCategories &&
      memoCategories.length > 0 ? memoCategories[0] : "할 일",
    title: "처리 실패한 메모",
    content: memoText || "",
    tags: [],
  };
};

// 메모 분석 함수
exports.analyzeMemo = onCall({
  secrets: ["GEMINI_API_KEY"],
}, async (request, context) => {
  // request.data에서 직접 추출
  const data = request.data || {};
  const memoText = data.memoText || "";
  const categories = data.categories || ["할 일", "공부", "아이디어"];

  // 추가
  const mode = data.mode || "default" 

  console.log("데이터 수신:", data);
  console.log("memoText:", memoText);
  console.log("categories:", categories);
  console.log("default", mode);

  // 모드에 따라 카테고리 결정
  // let filteredCategories;
  // if (mode == "todo") {
  //   filteredCategories = ["할 일"]; // 할일 페이지에서는 할일 카테고리만
  // } else {
  //   filteredCategories = ["공부", "아이디어"];
  // }
  let filteredCategories = mode === "todo" ? ["할 일"] : ["공부", "아이디어"];


  // 메모 내용 검증
  if (!memoText) {
    console.error("메모 내용 누락");
    return createErrorResponse("메모 내용이 필요합니다.", "", ["할 일"]);
  }

  // 카테고리가 없으면 기본값 설정
  // const memoCategories = categories || ["할 일", "공부", "아이디어"];
  const memoCategories = filteredCategories;

  // 환경 변수에서 API 키 가져오기
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    console.error("Gemini API 키가 설정되지 않았습니다.");
    return createErrorResponse("서버 구성 오류: API 키가 없습니다.",
        memoText, memoCategories);
  }

  // Gemini 클라이언트 초기화
  const ai = new genai.GoogleGenAI({apiKey});

  // 프롬프트 구성
  const prompt = `
    아래의 메모를 분류해줘
    ${memoText}
    분류할 수 있는 카테고리는 다음과 같아
    ${memoCategories} 중 하나로 분류해야 해.
    그리고 10자 이내의 적절한 제목도 붙여줘야 해.
    또한 메모 원문을 그대로 복사해서 붙여넣어야 해.
    또한 1개에서 3개의 태그를 붙여야 해.
    특히 조심해. 아래의 JSON 형식은 말 그대로 예시일 뿐이고
    네가 적절히 판단해서 최적의 태그 갯수를 산정한 다음에 태그를 붙이도록 해.
    그리고 마지막으로 메모 원문을 보고 카테고리가 공부라고 판단했을 경우
    이 내용을 가지고 복습이 가능하도록 질문을 하나 만들어줘.
    아래와 같이 JSON 형식으로 답변할 수 있도록 해
    답변할 때는 쓸데없는 말 추가하지 말고 오직 아래 형식으로 [json 코드블록만] 출력해.
    {
      "category": "카테고리",
      "title": "제목",
      "content": "메모 원문",
      "tags": ["태그1", "태그2", ...],
      "question": "content 내용으로 만든 질문"
    }
  `;

  // Gemini API 호출 - Promise 처리 방식으로 변경
  const generateContentPromise = ai.models.generateContent({
    model: "gemini-2.0-flash",
    contents: prompt,
  });

  // Promise의 결과를 then으로 처리하지 않고 await으로 직접 받되, 오류 처리는 외부에서
  const responseObject = await generateContentPromise.catch((apiError) => {
    console.error("Gemini API 호출 오류", apiError);
    // null을 반환하여 오류 상태 표시
    return null;
  });

  // API 호출 실패 처리
  if (!responseObject) {
    return createErrorResponse("AI 서비스 호출 중 오류가 발생했습니다.",
        memoText, memoCategories);
  }

  const responseText = responseObject.candidates[0].content.parts[0].text;

  // 마크다운 코드 블록 제거 (```json과 ``` 부분 제거)
  const cleanedText = responseText.replace(/```json\n|\n```/g, "");

  // JSON 파싱
  const safeJSONParse = (text) => {
    try {
      return {success: true, data: JSON.parse(text)};
    } catch (e) {
      console.error("JSON 파싱 오류 원본 텍스트:", text);
      return {success: false, error: e};
    }
  };

  const parsedResult = safeJSONParse(cleanedText);

  // 파싱 실패 처리
  if (!parsedResult.success) {
    console.error("JSON 파싱 오류", parsedResult.error);
    return createErrorResponse("AI 응답 처리 오류: JSON 파싱 실패",
        memoText, memoCategories);
  }

  const parsedResponse = parsedResult.data;

  // 응답 반환
  return parsedResponse;
});

// 테스트용 기본 함수 (onRequest 유지)
exports.helloWorld = onRequest((request, response) => {
  console.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

exports.testEcho = onCall({}, async (data, context) => {
  console.log("데이터 수신:", data);
  return {echo: data};
});
