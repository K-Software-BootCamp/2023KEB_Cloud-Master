import React from "react";
import { BrowserRouter as Router, Route, Routes, Link } from "react-router-dom";
// import Form from "./Form";
import Login from "./login";
import SignUp from "./signup";
import Post from "./post";
import BoardList from "./boardList"; // Import the BoardList component
import MyPage from "./myPage";

function App() {
  return (
    <Router>
      <div>
      <nav className="navbar navbar-expand-lg navbar-light bg-dark">
      <div className="container">
        <ul className="navbar-nav mx-auto">
          <li className="nav-item">
            <Link to="/" className="nav-link text-white">
              Home
            </Link>
          </li>
          <li className="nav-item">
            <Link to="/boardList" className="nav-link text-white">
              List
            </Link>
          </li>
          <li className="nav-item">
            <Link to="/myPage" className="nav-link text-white">
              MyPage
            </Link>
          </li>
          <li className="nav-item">
            <Link to="/post" className="nav-link text-white">
              Post
            </Link>
          </li>
        </ul>
      </div>
    </nav>

        <Routes>
          
          <Route path="/login" element={<Login />} />
          <Route path="/signup" element={<SignUp />} />
          <Route path="/post" element={<Post />} />
          <Route path="/boardList" element={<BoardList />} />
          <Route path="/myPage" element={<MyPage />} />
          <Route path="/boardList" element={<BoardList />} />
        </Routes>
        
      </div>
    </Router>
  );
}

export default App;
