# Installation Instructions

Follow the steps below to set up the project:

1. **Clone the Repository**
   ```bash
   git clone https://github.com/galvani/enviros-dev-env
   ```

2. **Initialize Submodules**
   ```bash
   git submodule update --init --recursive
   ```

3. **Set Up Environment Configuration**
    - Copy the default environment file:
      ```bash
      cp .env.dist .env
      ```
    - Open the `.env` file and adjust the settings to match your environment.

4. **Adjust Application Environment**
    - Navigate to the `app` directory:
      ```bash
      cd app
      ```
    - Set the `APP_ENV` variable in `.env` to match your environment (one of `test`, `dev`, or `prod`).
    - If you set `APP_ENV=dev`, adjust the `.env.dev` file to configure development-specific settings.

5. **Optional: Local Overrides**
    - To override any settings, create a `.env.local` file. This file will take precedence over others.

6. **Install Dependencies**
   ```bash
   composer install
   ```

