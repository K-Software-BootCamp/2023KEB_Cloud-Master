import React, { Component } from "react";
import axios from "axios";
import "./css/Form.css";

export class Form extends Component {
  constructor(props) {
    super(props);
    this.state = {
      id: "",
      name: "",
      pw: "",
      items: [], // holds the items fetched from the API
      getItemId: "", // 데이터 조회
      deleteItemId: "", // 데이터 삭제
      chkId: "",
      chkPw: "",
      isLoggedIn: false,
      isError: false,
      loginMessage: "",
      errorMessage: "",
      systemMessage: "",
      file: null,
      type: null,

      userId: "",
      image: "", //sendImgS3()를 통해 받아온 이미지 데이터
      boardTitle: "",
      boardContent: "",
      boardCategory: "",
      rate: 0,
    };
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleChange = this.handleChange.bind(this);
    this.handleGetItem = this.handleGetItem.bind(this);
    this.handleGetAllItem = this.handleGetAllItem.bind(this);
    this.handleDeleteItem = this.handleDeleteItem.bind(this);
    this.handleLogin = this.handleLogin.bind(this);
    this.handleFileUpload = this.handleFileUpload.bind(this); // s3
    this.handleFileChange = this.handleFileChange.bind(this);
    // ㄱㅔ시물
    this.sendBoardData = this.sendBoardData.bind(this);
  }

  handleChange(event) {
    const inputValue = event.target.value;
    const stateField = event.target.name;
    this.setState({
      [stateField]: inputValue,
    });
    console.log(this.state);
  }
  handleFileChange(event) {
    this.setState({
      file: event.target.files[0],
    });
  }

  // 데이터 저장 (dynamoDB)
  async handleSubmit(event) {
    event.preventDefault();
    try {
      const { id, pw, name } = this.state;
      await axios.put("/items", { id: `${id}`, pw: `${pw}`, name: `${name}` });
      this.setState({ systemMessage: `Sign Up 성공!!!` });
    } catch (error) {
      console.error("Error get item:", error);
      this.setState({ systemMessage: `Sign Up 실패...` });
    }
  }
  // 게시물
  async sendBoardData(event) {
    event.preventDefault();
    try {
      const { userId, image, boardTitle, boardContent, boardCategory, rate } =
        this.state;
      await axios.put("/boards", {
        userId: `${userId}`,
        image: `${image}`,
        boardTitle: `${boardTitle}`,
        boardContent: `${boardContent}`,
        boardCategory: `${boardCategory}`,
        rate: `${rate}`,
      });
      this.setState({ systemMessage: `게시물 업로드 성공!!!` });
    } catch (error) {
      console.error("Error get item:", error);
      this.setState({ systemMessage: `게시물 업로드 실패...` });
    }
  }

  // 전체 데이터 조회
  async handleGetAllItem(event) {
    event.preventDefault();
    try {
      const response = await axios.get(`/items`);
      this.setState({
        items: response.data,
        systemMessage: `전체 데이터 조회 성공!!!`,
      });
      console.log("handleGetItem state:", this.state, response);
    } catch (error) {
      console.error("Error get item:", error);
      this.setState({ systemMessage: `전체 데이터 조회 실패...` });
    }
  }

  // 개별 데이터 조회 (id)
  async handleGetItem(event) {
    event.preventDefault();
    const { getItemId } = this.state;

    try {
      const response = await axios.get(`/items/${getItemId}`);
      this.setState({
        items: [response.data],
        systemMessage: `ID ${getItemId} 조회 성공!!!`,
      });
      console.log("handleGetItem state:", this.state, response);
    } catch (error) {
      console.error("Error get item:", error);
      this.setState({ systemMessage: `조회 실패 (해당 ID 없음)...` });
    }
  }

  // 개별 데이터 삭제 (id)
  async handleDeleteItem(event) {
    event.preventDefault();
    const { deleteItemId } = this.state;

    try {
      await axios.delete(`/items/${deleteItemId}`);
      this.setState({
        deleteItemId: "",
        systemMessage: `ID ${deleteItemId} 삭제 성공!!!`,
      });
    } catch (error) {
      console.error("Error deleting item:", error); // 없는 id 삭제 해도 성공으로 뜸
      this.setState({ systemMessage: `삭제 실패...` });
    }
  }

  // s3 업로드
  async handleFileUpload(event) {
    event.preventDefault();

    // Check if a file was selected before proceeding
    if (!this.state.file) {
      console.error("No file selected.");
      this.setState({ systemMessage: ` No file selected.` });

      return;
    }

    // Create a new FormData instance
    const formData = new FormData();

    // Add the file to the form data
    formData.append("file", this.state.file, this.state.file.name);

    // Send the POST request
    try {
      await axios.post("/files", formData, {
        headers: {
          "Content-Type": "multipart/form-data",
        },
      });

      this.setState({ systemMessage: ` 업로드 성공!!!` });

      console.log("File uploaded successfully!");
    } catch (error) {
      console.error("File upload failed:", error);
      this.setState({ systemMessage: ` 업로드 실패...` });
    }
  }

  // 로그인
  async handleLogin(event) {
    event.preventDefault();
    const { chkId, chkPw } = this.state;
    try {
      const response = await axios.get(`/items/${chkId}`);
      const item = response.data;

      if (item && item.pw === chkPw) {
        this.setState({
          isLoggedIn: true,
          isError: false,
          loginMessage: `ID ${chkId} 로그인 성공!!!`,
        });
      } else {
        this.setState({
          isLoggedIn: false,
          isError: true,
          errorMessage: "로그인 실패 (ID 또는 비밀번호가 일치하지 않습니다)...",
        });
      }
    } catch (error) {
      console.error("Error get item:", error);
      this.setState({
        isLoggedIn: false,
        isError: true,
        errorMessage: "로그인 실패 (해당 ID 없음)...",
      });
      // alert(`로그인 실패 (해당 ID 없음)...`)
    }
  }

  render() {
    const { isLoggedIn, isError, loginMessage, errorMessage, systemMessage } =
      this.state;

    return (
      <div className="form-wrapper">
        {/* Display System Message */}
        <h1 className="system-message">{systemMessage}</h1>
        <h1 className="main-heading">Form.js</h1>

        {/* Sign Up */}
        <div className="form-container">
          <form onSubmit={this.handleSubmit} className="form-item">
            <h2>Sign Up</h2>
            <div className="input-field">
              <input
                type="text"
                name="id"
                onChange={this.handleChange}
                value={this.state.id}
                placeholder="id"
                className="input-field"
              />
            </div>
            <div className="input-field">
              <input
                type="text"
                name="pw"
                onChange={this.handleChange}
                value={this.state.pw}
                placeholder="pw"
                className="input-field"
              />
            </div>
            <div className="input-field">
              <input
                type="text"
                name="name"
                onChange={this.handleChange}
                value={this.state.name}
                placeholder="name"
                className="input-field"
              />
            </div>
            <button type="submit" className="submit-button">
              Sign Up
            </button>
          </form>
        </div>

        {/* Login */}
        <div className="form-container">
          <form onSubmit={this.handleLogin} className="form-item">
            <label className="form-label"> ** Login ** </label>
            <div className="input-field">
              <input
                type="text"
                name="chkId"
                onChange={this.handleChange}
                value={this.state.chkId}
                placeholder="id"
                className="input-field"
              />
            </div>
            <div className="input-field">
              <input
                type="text"
                name="chkPw"
                onChange={this.handleChange}
                value={this.state.chkPw}
                placeholder="pw"
                className="input-field"
              />
            </div>
            <button type="submit" className="submit-button">
              Login
            </button>
          </form>
        </div>

        {/* Display Login Result */}
        {isLoggedIn && <h1 className="login-message">{loginMessage}</h1>}
        {isError && <h1 className="error-message">{errorMessage}</h1>}

        {/* Get All Items Button */}
        <button
          type="button"
          className="submit-button"
          onClick={this.handleGetAllItem}
        >
          Get All Items
        </button>

        <div className="form-container">
          {/* Add a form for file uploads */}
          <form
            onSubmit={this.handleFileUpload}
            className="form-item board-form"
          >
            <h2>Upload file (text file only)</h2>
            <input
              type="file"
              onChange={this.handleFileChange}
              className="input-field"
            />
            <button type="submit" className="submit-button">
              Upload File
            </button>
          </form>

          {/* Get Item by ID Form */}
          <form onSubmit={this.handleGetItem} cclassName="form-item board-form">
            <h2>Get ID</h2>
            <input
              type="text"
              name="getItemId"
              onChange={this.handleChange}
              value={this.state.getItemId}
              className="input-field"
            />
            <button type="submit" className="submit-button">
              Get Item
            </button>
          </form>

          {/* Delete Item by ID Form */}
          <form
            onSubmit={this.handleDeleteItem}
            className="form-item board-form"
          >
            <h2>Delete ID</h2>
            <input
              type="text"
              name="deleteItemId"
              onChange={this.handleChange}
              value={this.state.deleteItemId}
              className="input-field"
            />
            <button type="submit" className="submit-button">
              Delete Item
            </button>
          </form>
        </div>
        
        {/* 게시물 작성 */}
        <div className="form-container">
          <form onSubmit={this.sendBoardData} className="form-item board-form">
            <h2>게시물 작성</h2>
            <div className="input-field">
              <input
                type="text"
                name="userId"
                onChange={this.handleChange}
                // value={this.state.userId}
                value={localStorage.getItem('userId')}

                placeholder="사용자 ID"
                className="input-field"
              />
            </div>
            <div className="input-field">
              <input
                type="text"
                name="image"
                onChange={this.handleChange}
                value={this.state.image}
                placeholder="이미지 URL"
                className="input-field"
              />
            </div>
            <div className="input-field">
              <input
                type="text"
                name="boardTitle"
                onChange={this.handleChange}
                value={this.state.boardTitle}
                placeholder="게시물 제목"
                className="input-field"
              />
            </div>
            <div className="input-field">
              <textarea
                onChange={this.handleChange}
                value={this.state.boardContent}
                name="boardContent"
                placeholder="게시물 내용"
                className="input-field textarea-field"
              />
            </div>
            <div className="input-field">
              <input
                type="text"
                name="boardCategory"
                onChange={this.handleChange}
                value={this.state.boardCategory}
                placeholder="게시물 카테고리"
                className="input-field"
              />
            </div>
            <div className="input-field">
              <input
                type="number"
                name="rate"
                onChange={this.handleChange}
                value={this.state.rate}
                placeholder="평점"
                className="input-field"
              />
            </div>
            <button type="submit" className="submit-button">
              게시물 업로드
            </button>
          </form>
        </div>

        {/* List output */}
        {Array.isArray(this.state.items) &&
          this.state.items.map(
            (item, index) =>
              item && (
                <div key={index} className="item-container">
                  <p>Created Date: {item.date}</p>
                  <p>ID: {item.id}</p>
                  <p>Password: {item.pw}</p>
                  <p>Name: {item.name}</p>
                </div>
              )
          )}
      </div>
    );
  }
}
export default Form; // Form 컴포넌트를 일반적인 내보내기로 설정
