# RefundTracker Pro - Complete Navigation Guide

## 🏠 Main App Structure

### 📱 App Entry Points
- **Welcome Screen** (`/welcome`) - First launch experience
- **Main Screen** (`/main`) - Main app with dashboard and settings tabs

### 🎯 Core Navigation Flow
```
App Launch → Welcome Screen (first time) → Main Screen
                                    ↓
                              Dashboard Tab ←→ Settings Tab
```

---

## 📊 Dashboard Tab

### 🏠 Dashboard Screen (`/dashboard`)
- **Per-Item Mode**: Shows individual expense items with progress
- **Pool Mode**: Shows pool summary with validation warnings
- **Hybrid Mode**: Tabbed interface with Items/Pool sections
- **Solana Mode**: Token-based dashboard with wallet health
- **Value Mode**: Dynamic balance tracking with timeline

### ➕ Add Item Screen (`/add-item`)
- Add new expense items
- Set amount, title, notes, and date
- Available in Per-Item and Hybrid modes

### 💰 Add Refund Screen (`/add-refund`)
- Add refunds to specific items
- Set amount, notes, and date
- Available in all modes

### 📋 Item Detail Screen (`/item-detail`)
- Detailed view of individual expense items
- Shows refund history and progress
- Available in Per-Item and Hybrid modes

---

## ⚙️ Settings Tab

### 🔧 Settings Screen (`/settings`)
- **Tracking Mode Selection**:
  - Per-Item Tracking
  - Pool Tracking  
  - Hybrid Tracking
  - Solana Mode
  - Value Mode
- **Notifications**: Access to CashFlow Comedian
- **Data Management**: Export and Clear Data
- **App Information**: Version and build info

### 🎤 Notification Settings Screen (`/notification-settings`)
- **CashFlow Comedian Configuration**:
  - Enable/Disable notifications
  - Low power mode toggle
  - Humor style selection (Savage, Dad Jokes, Mascot, Friendly)
  - Test notification buttons
  - Humor profile and learning scores

---

## 🎯 Mode-Specific Features

### 📦 Per-Item Mode
- Individual expense tracking
- Item-specific refunds
- Progress visualization
- Item detail views

### 🏦 Pool Mode
- Single pool for all expenses
- Pool-level refunds
- Validation warnings
- Maximum refundable calculations

### 🔗 Hybrid Mode
- Combined per-item and pool tracking
- Tabbed interface (Items/Pool)
- Cross-mode insights
- Combined totals display

### 🪙 Solana Mode
- Token-based economy
- Wallet health indicators
- Mascot system
- Token locking/unlocking

### 💹 Value Mode
- Dynamic balance tracking
- Historical timeline
- Asset revaluation
- Future projections

---

## 🎵 Sound Setup

### 📁 Sound File Location
```
android/app/src/main/res/raw/cha_ching.wav
```

### 🎯 Requirements
- WAV format only
- Exact filename: `cha_ching.wav`
- 1-3 seconds duration
- Cash register or "cha-ching" sound

---

## 🚀 How to Access All Pages

### 1. **Welcome Screen**
- Automatically shown on first app launch
- Access via: `Navigator.pushNamed(context, '/welcome')`

### 2. **Main Dashboard**
- Default screen after welcome
- Access via: `Navigator.pushNamed(context, '/main')`

### 3. **Add Item**
- From dashboard: Tap "+" button
- Access via: `Navigator.pushNamed(context, '/add-item')`

### 4. **Add Refund**
- From item detail or dashboard
- Access via: `Navigator.pushNamed(context, '/add-refund')`

### 5. **Item Detail**
- From dashboard: Tap on any item
- Access via: `Navigator.pushNamed(context, '/item-detail')`

### 6. **Settings**
- From main screen: Tap Settings tab
- Access via: Bottom navigation

### 7. **Notification Settings**
- From settings: Tap "CashFlow Comedian"
- Access via: `Navigator.pushNamed(context, '/notification-settings')`

### 8. **Export Screen**
- From settings: Tap "Export Data"
- Access via: `Navigator.pushNamed(context, '/export')`

---

## 🎨 UI/UX Features

### 🎯 Consistent Design
- Gradient backgrounds
- Rounded corners
- Shadow effects
- Mode-specific accent colors

### 📱 Responsive Layout
- Adaptive to different screen sizes
- Bottom navigation
- Tabbed interfaces where needed

### 🎵 Interactive Elements
- Haptic feedback
- Smooth animations
- Loading states
- Error handling

---

## 🔧 Technical Implementation

### 📱 Navigation
- Named routes in `main.dart`
- Bottom navigation in `main_screen.dart`
- Tab controllers for complex screens

### 🎤 Notifications
- Background task scheduling
- Local notification system
- Humor personalization
- Battery optimization

### 💾 Data Management
- SQLite database
- Provider state management
- Data persistence
- Export functionality

---

## 🎯 Complete Feature Matrix

| Feature | Per-Item | Pool | Hybrid | Solana | Value |
|---------|----------|------|--------|--------|-------|
| Add Expenses | ✅ | ✅ | ✅ | ✅ | ✅ |
| Add Refunds | ✅ | ✅ | ✅ | ✅ | ✅ |
| Progress Tracking | ✅ | ✅ | ✅ | ✅ | ✅ |
| Item Details | ✅ | ❌ | ✅ | ✅ | ✅ |
| Validation | ✅ | ✅ | ✅ | ✅ | ✅ |
| Notifications | ✅ | ✅ | ✅ | ✅ | ✅ |
| Export Data | ✅ | ✅ | ✅ | ✅ | ✅ |
| Mode Switching | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## 🚀 Getting Started

1. **Install Dependencies**: `flutter pub get`
2. **Add Sound File**: Place `cha_ching.wav` in `android/app/src/main/res/raw/`
3. **Run the App**: `flutter run`
4. **Navigate**: Use bottom tabs and on-screen buttons
5. **Test Notifications**: Go to Settings → Notifications → Test buttons

---

## 🎉 All Pages Are Now Accessible!

Every page in the RefundTracker Pro app is now properly connected and accessible through the navigation system. The CashFlow Comedian notification system is fully integrated and ready to make your financial tracking experience fun and engaging! 🎤💸
