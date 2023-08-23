import React, { Component } from "react";
import axios from "axios";
// import "./css/Form.css";
import { BrowserRouter as Router, Route, Routes, Link } from "react-router-dom";
// import Form from "react-bootstrap/Form";
import shortId from "shortid";
import "bootstrap/dist/css/bootstrap.min.css";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";

export class Post extends Component {
  constructor(props) {
    super(props);
    this.state = {
      items: [],
      boards: [],
      getUserId: "", // Change this to getUserId
      getDate: "", // Add this state for date
      deleteItemId: "", // 데이터 삭제
      isLoggedIn: false,
      isError: false,
      loginMessage: "",
      errorMessage: "",
      systemMessage: "",
      file: null,
      type: null,

      userId: "",
      postId: "",
      image: "", //sendImgS3()를 통해 받아온 이미지 데이터
      boardTitle: "",
      boardContent: "",
      boardCategory: "category1",
      rate: 0,
      selectedFile: null,
      uploadedImageUrl: null,
    };
    this.handleChange = this.handleChange.bind(this);
    this.handleFileChange = this.handleFileChange.bind(this);
    // ㄱㅔ시물
    this.sendBoardData = this.sendBoardData.bind(this);
    this.getBoardList = this.getBoardList.bind(this);
    this.handleCategoryChange = this.handleCategoryChange.bind(this);
    this.handleRateClick = this.handleRateClick.bind(this);
    this.handleGetPost = this.handleGetPost.bind(this);
  }

  handleChange(event) {
    const inputValue = event.target.value;
    const stateField = event.target.name;
    this.setState({
      [stateField]: inputValue,
    });
    console.log(this.state);
  }
  handleFileChange = (event) => {
    this.setState({
      selectedFile: event.target.files[0],
      uploadedImageUrl: null, // Reset uploaded image URL when selecting a new file
    });
  };

  // 게시물
  async sendBoardData(event) {
    event.preventDefault();
    const {
      userId,
      postId,
      image,
      boardTitle,
      boardContent,
      boardCategory,
      rate,
    } = this.state;

    if (!userId) {
      this.setState({ systemMessage: `로그인 되어 있지 않음.,..` });
      return;
    }
    try {
      await axios.put("/boards", {
        userId: `${userId}`,
        postId: `${postId}`,
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

  async getBoardList(event) {
    event.preventDefault();
    try {
      const response = await axios.get(`/boards`);
      this.setState({
        items: response.data,
        systemMessage: `전체 게시물 조회 성공!!!`,
      });
      console.log("handleGetItem state:", this.state, response);
    } catch (error) {
      console.error("Error get item:", error);
      this.setState({ systemMessage: `전체 게시물 조회 실패...` });
    }
  }

  // 개별 데이터 조회 (id)
  async handleGetPost(event) {
    event.preventDefault();
    const { getUserId, getDate } = this.state;

    try {
      const response = await axios.get(`/boards/${getUserId}/${getDate}`); // Change the GET URL
      this.setState({
        items: [response.data],
        systemMessage: `User ID ${getUserId}, Date ${getDate} 조회 성공!!!`,
      });
      console.log("handleGetItem state:", this.state, response);
      console.log("조회 성공");
    } catch (error) {
      console.error("Error get item:", error);
      console.log("조회 실패");
      this.setState({ systemMessage: `조회 실패 (해당 ID 또는 날짜 없음)...` });
    }
  }

  async handleCategoryChange(event) {
    const selectedCategory = event.target.value;
    const isChecked = event.target.checked;

    this.setState((prevState) => {
      let updatedCategories;
      if (isChecked) {
        updatedCategories = [...prevState.boardCategory, selectedCategory];
      } else {
        updatedCategories = prevState.boardCategory.filter(
          (category) => category !== selectedCategory
        );
      }

      return {
        boardCategory: updatedCategories,
      };
    });
  }

  // 게시물 별점 저장하기
  async handleRateClick(rate) {
    this.setState({ rate });
  }
  // 별 아이콘을 그리는 함수
  showStars(value) {
    const fullStars = Math.floor(value);
    const halfStar = value - fullStars >= 0.5 ? true : false;
    const emptyStars = 5 - Math.ceil(value);

    return (
      <div className="star-rating">
        {[...Array(fullStars)].map((_, index) => (
          <span key={index} className="star selected">
            ★
          </span>
        ))}
        {halfStar && (
          <span className="star selected">
            <span className="half-star">★</span>
          </span>
        )}
        {[...Array(emptyStars)].map((_, index) => (
          <span key={index} className="star">
            ★
          </span>
        ))}
      </div>
    );
  }

  handleUpload = async () => {
    const { selectedFile, systemMessage } = this.state;

    if (!selectedFile) {
      alert("Please select a file.");
      return;
    }

    const formData = new FormData();
    formData.append("file", selectedFile);

    try {
      const response = await axios.post("/upload", formData, {
        headers: {
          "Content-Type": "multipart/form-data",
        },
      });

      const uploadedImageUrl = response.data.imageUrl;
      this.setState({ uploadedImageUrl });
    } catch (error) {
      console.error("Error uploading image:", error);
      console.log(error.response); // Check the error response
    }
  };

  render() {
    const { isLoggedIn, systemMessage, rate, uploadedImageUrl } = this.state;

    return (
      <div className="container mt-4">
        <header className="app-header">
          <h1>Board</h1>
        </header>

        <div className="form-container mt-4">
          <Form onSubmit={this.sendBoardData} className="form-item board-form">
            <h2>게시물 작성</h2>
            <Form.Group>
              <Form.Label>작성자</Form.Label>
              <p>{(this.state.userId = localStorage.getItem("userId"))}</p>
            </Form.Group>
            <Form.Group>
              <Form.Label>게시물 Id</Form.Label>
              <p>{(this.state.postId = shortId.generate())}</p>
            </Form.Group>

            <Form.Group>
              <Form.Label>게시물 제목</Form.Label>
              <Form.Control
                type="text"
                name="boardTitle"
                onChange={this.handleChange}
                value={this.state.boardTitle}
                placeholder="게시물 제목"
              />
            </Form.Group>

            <Form.Group>
              <Form.Label>이미지 업로드</Form.Label>
              <Form.Control
                type="file"
                accept="image/*"
                onChange={this.handleFileChange}
              />
              <Button variant="info" onClick={this.handleUpload}>
                Upload
              </Button>
              {uploadedImageUrl && (
                <div>
                  <h3>Uploaded Image:</h3>
                  <img src={uploadedImageUrl} alt="Uploaded" />
                </div>
              )}
            </Form.Group>

            <Form.Group>
              <Form.Label>카테고리 선택</Form.Label>
              <Form.Control
                as="select"
                id="boardCategory"
                name="boardCategory"
                value={this.state.boardCategory}
                onChange={this.handleChange}
              >
                <option value="category1">Category 1</option>
                <option value="category2">Category 2</option>
                <option value="category3">Category 3</option>
                <option value="category4">Category 4</option>
              </Form.Control>
            </Form.Group>

            <Form.Group>
              <Form.Label>게시물 내용</Form.Label>
              <Form.Control
                as="textarea"
                onChange={this.handleChange}
                value={this.state.boardContent}
                name="boardContent"
                placeholder="게시물 내용"
              />
            </Form.Group>

            <Form.Group>
              <Form.Label>별점 선택</Form.Label>
              <div className="star-rating">
                {[1, 2, 3, 4, 5].map((value) => (
                  <span
                    key={value}
                    className={`star ${value <= rate ? "selected" : ""}`}
                    onClick={() => this.handleRateClick(value)}
                  >
                    ★
                  </span>
                ))}
              </div>
              <p>선택한 평점: {rate}</p>
            </Form.Group>

            <Button type="submit" variant="primary">
              게시물 업로드
            </Button>
          </Form>
        </div>

        <Link to="/boardList" className="btn btn-secondary mt-3">
          게시물 리스트 페이지로 이동
        </Link>

        <Button
          type="button"
          variant="info"
          className="mt-3"
          onClick={this.getBoardList}
        >
          Get All Boards
        </Button>

        {/* List output */}

        {Array.isArray(this.state.items) &&
          this.state.items.map(
            (item, index) =>
              item && (
                <div key={index} className="item-container mt-4">
                  <p>Created Date: {item.date}</p>
                  <p>UserID: {item.userId}</p>
                  <p>PostID: {item.postId}</p>
                  <p>BoardTitle: {item.boardTitle}</p>
                  <p>Img: {item.image}</p>
                  <p>BoardCategory: {item.boardCategory}</p>
                  <div className="rate-container">
                    {this.showStars(item.rate)}
                  </div>
                </div>
              )
          )}

        <h3 className="system-message mt-3">{systemMessage}</h3>
      </div>
    );
  }
}

export default Post;
