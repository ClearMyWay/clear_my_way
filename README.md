# clear_my_way

## Deployment Instructions

### Prerequisites

Ensure you have the following installed on your Linux computer:
- Node.js and npm
- Flutter SDK
- Dart SDK
- MongoDB
- Git

### Backend Deployment

1. Clone the repository:
    ```sh
    git clone <repository-url>
    cd clear_my_way/backend
    ```

2. Install backend dependencies:
    ```sh
    npm install
    ```

3. Set up environment variables:
    Create a `.env` file in the `backend` directory and add the necessary environment variables (e.g., MongoDB URI, JWT secret).

4. Start the MongoDB service:
    ```sh
    sudo systemctl start mongod
    ```

5. Start the backend server:
    ```sh
    npm run start
    ```

### Frontend Deployment

1. Navigate to the Flutter project directory:
    ```sh
    cd ../clrmyway
    ```

2. Install Flutter dependencies:
    ```sh
    flutter pub get
    ```

3. Build the Flutter web project:
    ```sh
    flutter build web
    ```

4. Serve the Flutter web project:
    ```sh
    cd build/web
    python3 -m http.server 8000
    ```

### Access the Application

Open your web browser and navigate to `http://localhost:8000` to access the application.

### Additional Notes

- Ensure that the backend server is running before accessing the frontend.
- You may need to adjust firewall settings to allow access to the specified ports.
- For production deployment, consider using a web server like Nginx or Apache to serve the Flutter web build and a process manager like PM2 for the Node.js backend.

## License

This project is licensed under the MIT License.