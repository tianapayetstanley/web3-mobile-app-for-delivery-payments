import ReactDOM from "react-dom/client";
import App from "./App";
import "./index.css";
// cwk contribution added about page
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import ErrorPage from "./components/Error";

import AddCheckpoint from "./components/AddCheckpoint";
import About from "./components/About";

const router = createBrowserRouter([
  {
    path: "/",
    element: <App />,
    errorElement: <ErrorPage />,
  },

  {
    path: "addCheckpoint",
    element: <AddCheckpoint />,
  },
  {
    path: "about",
    element: <About />,
  },
]);
ReactDOM.createRoot(document.getElementById("root")).render(
  <RouterProvider router={router} />
);