# POS System (Point of Sale)

A comprehensive, production-grade Point of Sale (POS) application built with **Flutter**. This system is designed for retail and restaurant environments, offering a seamless experience across tablet (desktop-like) and mobile devices. It features robust order management, real-time sales analytics, and direct hardware integration for thermal printing.

## 🌟 Key Features

### 🛒 Point of Sale (POS) Terminal
- **Responsive Design**:
  - **Tablet/Desktop Mode**: A productivity-focused 3-column layout (Categories | Products | Cart) for high-volume environments.
  - **Mobile Mode**: A streamlined interface with a collapsible bottom-sheet cart, perfect for handheld ordering.
- **Product Management**:
  - Browse products by **Categories** and **Subcategories**.
  - View special **Offers** and active promotions.
  - Fast product search and grid display.
- **Cart & Ordering**:
  - Real-time total calculation.
  - One-tap add/remove/increment items.
  - Clear cart management (clear all, specific item deletion).
  - Submit orders directly to the backend API.

### 📜 Order History & Management
- **Transaction Log**: View a complete history of all past orders (`OrdersHistoryScreen`).
- **Order Details**: Inspect specific items, prices, and timestamps for any past transaction.
- **Edit Orders**: Capability to modify existing orders (update items/quantities) and sync changes with the server.

### 📊 Sales Analytics
- **Dashboard**: Visual insights into business performance.
- **Reports**:
  - **Sales Summary**: Total revenue within specific date ranges.
  - **Top Products**: Identify best-selling items.
  - **Daily Sales**: Track performance trends over the last 7 days.

### 🖨️ Hardware & Printing
- **Thermal Receipt Printing**:
  - Direct integration with **QZ Tray** technology for raw printing.
  - Generates professional HTML-based receipts with Arabic (RTL) support.
  - Customizable printer targeting (default `"Reference POS"`).
- **PDF Generation**:
  - Automatic PDF creation for receipts.
  - In-app PDF previewing and sharing.

---

## 🏗️ Architecture & Tech Stack

The project follows **Clean Architecture** principles to ensure scalability, testability, and maintainability.

### Core Technologies
- **Framework**: Flutter (Dart SDK ^3.9.2)
- **State Management**: `flutter_bloc` & `cubit` pattern.
- **Networking**: `http` package with a custom `ApiService` wrapper.
- **WebSocket**: `web_socket_channel` for QZ Tray communication.
- **Utilities**: `intl` (formatting), `printing`, `pdf`.

### Folder Structure
```
lib/
├── core/
│   ├── config/         # App configuration (e.g., ApiConfig)
│   ├── constants/      # Static constants (Colors, Strings)
│   └── theme/          # App theming and styles
├── data/
│   ├── models/         # Data models (Product, Order, Offer, etc.)
│   ├── services/       # External services (ApiService, QzTrayService)
│   └── repositories/   # Data repositories (PosRepository)
├── presentation/
│   ├── cubits/         # Business Logic Components (OrderCubit, SalesCubit)
│   └── views/          # UI Screens and Widgets
│       ├── home/       # Main POS interface
│       ├── history/    # Order history screens
│       ├── analytics/  # Sales dashboards
│       └── receipt/    # Receipt previewing
└── main.dart           # Application Entry Point
```

---

## ⚙️ Setup & Configuration

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
- [QZ Tray](https://qz.io/download/) (for printing features).
- A running backend server (ASP.NET Core recommended) providing the API endpoints.

### Installation

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd pos
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Endpoint**
   - Open `lib/core/config/api_config.dart`.
   - Update the `baseUrl` string to point to your backend server:
     ```dart
     static const String baseUrl = 'http://your-server-ip:port/api';
     ```

4. **Run the App**
   ```bash
   flutter run
   ```

### �️ Printer Configuration (QZ Tray)
To enable direct thermal printing:
1. **Install & Run QZ Tray**: Ensure it is running on the machine (default port `8182`).
2. **Configure Printer Name**:
   - The app looks for a printer named **"Reference POS"** by default.
   - To change this, edit `lib/presentation/views/home/widgets/order_summary.dart`:
     ```dart
     // Inside _OrderSummaryState
     _qzTrayService.printHtmlReceipt("Your Printer Name", ...);
     ```
   - Ensure the name matches exactly what is listed in your OS system printer settings.

---

## 🔌 API Endpoints

The application communicates with the following backend endpoints (defined in `ApiService`):

| Feature | Method | Endpoint | Description |
|---------|--------|----------|-------------|
| **Products** | GET | `/products` | List all products |
| | GET | `/products/category/{id}` | Filter by category |
| | GET | `/products/subcategory/{id}` | Filter by subcategory |
| **Categories** | GET | `/categories` | List main categories |
| **SubCategories** | GET | `/subcategories` | List subcategories |
| **Offers** | GET | `/offers/active` | List active offers |
| **Sales/Orders** | POST | `/sales/orders` | Create a new order |
| | GET | `/sales/orders` | Get order history |
| | PUT | `/sales/orders/{id}` | Update an existing order |
| **Analytics** | GET | `/sales/summary` | Get revenue summary |
| | GET | `/sales/top-products` | Get top sellers |
| | GET | `/sales/daily` | Get last 7 days sales |

---

## 📄 License

This project is licensed under the MIT License.
