import React, { Component } from "react";
import axios from "axios";
// import "./css/Form.css";
import { BrowserRouter as Router, Route, Routes, Link } from "react-router-dom";
import 'bootstrap/dist/css/bootstrap.min.css';
import Form from 'react-bootstrap/Form';
import Button from 'react-bootstrap/Button';
class SignUp extends Component {
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
      systemMessage: "",
    };
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleChange = this.handleChange.bind(this);
    this.handleGetAllItem = this.handleGetAllItem.bind(this);
  }

  handleChange(event) {
    const inputValue = event.target.value;
    const stateField = event.target.name;
    this.setState({
      [stateField]: inputValue,
    });
    console.log(this.state);
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

  render() {
    const { systemMessage } = this.state;

    return (
<div className="container mt-4">
        <h1 className="system-message">{systemMessage}</h1>
        <h1>SignUp Page</h1>

        <div className="form-container mt-4">
          <Form onSubmit={this.handleSubmit} className="form-item">
            <h2>Sign Up</h2>
            <Form.Group className="mb-3">
              <Form.Control
                type="text"
                name="id"
                onChange={this.handleChange}
                value={this.state.id}
                placeholder="ID"
              />
            </Form.Group>
            <Form.Group className="mb-3">
              <Form.Control
                type="password"
                name="pw"
                onChange={this.handleChange}
                value={this.state.pw}
                placeholder="Password"
              />
            </Form.Group>
            <Form.Group className="mb-3">
              <Form.Control
                type="text"
                name="name"
                onChange={this.handleChange}
                value={this.state.name}
                placeholder="Name"
              />
            </Form.Group>
            <Button type="submit" variant="primary">
              Sign Up
            </Button>
          </Form>
        </div>

        <button
          type="button"
          className="btn btn-secondary mt-3"
          onClick={this.handleGetAllItem}
        >
          Get All Items
        </button>

        <Link to="/login" className="btn btn-info mt-3">
          Go to Login page
        </Link>

        {Array.isArray(this.state.items) &&
          this.state.items.map(
            (item, index) =>
              item && (
                <div key={index} className="item-container mt-4">
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

export default SignUp;
