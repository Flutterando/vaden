---
sidebar_position: 1
---

# Full-Stack Development with Vaden

Vaden is a powerful framework that enables full-stack development using Dart, allowing you to build both the backend and frontend of your application with a single language. This guide will walk you through the structure and key concepts of a full-stack Vaden application, using a monorepo example.

In this model, we can organize our project into three key components:

1. **Backend (Vaden):** The server-side of our application is built with Vaden, a powerful Dart framework. It handles API requests, business logic, and database interactions.

2. **Frontend (Flutter):** The user interface is a cross-platform application developed with Flutter. It communicates with the Vaden backend to fetch and display data, providing a rich user experience on mobile, web, and desktop.

3. **Domain Package:** A central Dart package named `domain` contains the shared logic and data structures, such as data transfer objects (DTOs) and entities. This package is a dependency for both the backend and frontend projects, ensuring that both ends of the application speak the same language and reducing code duplication.

This monorepo setup allows for a seamless workflow, where changes in the `domain` package are instantly available to both the backend and frontend, fostering consistency and accelerating development.
