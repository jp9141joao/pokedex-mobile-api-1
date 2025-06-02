# Rick and Morty Mobile

A Flutter Web application that consumes the [Rick and Morty API](https://rickandmortyapi.com/) and integrates with Firebase Authentication for login, registration, and logout.

---

## Technologies

* **Flutter Web** (developed on [FlutLab](https://flutlab.io/))
* **Dart**
* **Firebase Auth** (email/password)
* **HTTP** (REST requests)
* **Google Fonts** (modern typography)
* **Rick and Morty API**

---

## Features

* **Login / Registration** with email and password validation (minimum 6 characters + `@`)
* **Route protection**: only authenticated users can access the character list
* **Paginated listing** of characters
* **Filters** by name, status, species, gender, and location
* **Logout**

---

## How to use

1. **Clone the repository**

   ```bash
   git clone https://github.com/jp9141joao/rick-and-morty-mobile.git
   cd mobile-project
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   * In the Firebase Console, create a project and add a Web app.
   * Copy the credentials (apiKey, authDomain, etc.) and paste them in `lib/main.dart` inside the `Firebase.initializeApp(options: ...)` block.

4. **Run in the browser**

   ```bash
   flutter run -d chrome
   ```

---

## Source code

* All Dart code is versioned on GitHub
* The main branch (`main`) contains the stable and functional version

---

## Application screenshots

![Login](assets/login.png)
![Registration](assets/register.png)
![Characters](assets/characters.png)
![Filters](assets/filters.png)

---

## Deployment link

* **Web Preview**: [https://preview.flutlab.io/user\_cfh/mobile-project/](https://preview.flutlab.io/user_cfh/mobile-project/)