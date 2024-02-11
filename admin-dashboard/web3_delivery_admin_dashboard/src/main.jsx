import ReactDOM from "react-dom/client";
import App from "./App";
import "./index.css";
// import ErrorBoundary from './components/ErrorBoundary'
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import ErrorPage from "./components/Error";

import AddCheckpoint from "./components/AddCheckpoint";

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
]);
ReactDOM.createRoot(document.getElementById("root")).render(
  <RouterProvider router={router} />
);
