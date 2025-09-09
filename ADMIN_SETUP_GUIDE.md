# 🏍️ DigitalBoda Admin App - Setup Guide

## 📱 **Separate Admin Application**

This is a **dedicated Flutter app** exclusively for DigitalBoda administrators to manage rider registrations and approvals.

---

## ✅ **Features**

### **🔐 Secure Admin Access**
- **Separate app** - Completely isolated from rider app
- **Admin-only authentication** with username/password
- **Professional dashboard** with statistics and overview

### **👥 Rider Management**
- **View all pending applications** with detailed information
- **Approve/Reject riders** with reasons and notes
- **Generate unique rider IDs** automatically (DB-YYYY-NNNN format)
- **Bulk operations** for efficient management

### **📊 Dashboard Features**
- **Real-time statistics** (total, pending, approved, rejected)
- **Beautiful UI** with professional design
- **Search and filter** riders by various criteria
- **Application tracking** with reference numbers

---

## 🚀 **Installation & Setup**

### **Step 1: Install the Admin App**

**For Android Devices:**
```bash
cd /home/katende/Desktop/DigitalBoda/digitalboda_admin
flutter build apk --release
```
Install the APK on admin devices only.

**For Desktop/Laptop:**
```bash
cd /home/katende/Desktop/DigitalBoda/digitalboda_admin
flutter run -d linux    # For Linux
flutter run -d windows  # For Windows  
flutter run -d macos    # For macOS
```

**For iOS:**
```bash
cd /home/katende/Desktop/DigitalBoda/digitalboda_admin
flutter build ios --release
```
Use Xcode to install on iOS devices.

### **Step 2: Admin Credentials**
- **Username:** `admin`
- **Password:** `admin123`

> ⚠️ **Important:** Change these credentials in production!

### **Step 3: Network Configuration**
Make sure admin devices can access the Django backend at:
```
http://192.168.1.19:8000/api/
```

---

## 📋 **How to Use**

### **1. Login**
- Open the **DigitalBoda Admin** app
- Enter admin credentials
- Access the professional dashboard

### **2. View Pending Applications**
- Dashboard shows **pending applications count**
- Click **"Review Pending Applications"**
- See all riders waiting for approval

### **3. Review Individual Riders**
- Click **"Review Application"** on any rider card
- View complete rider information:
  - Personal details (name, age, location)
  - Experience level
  - Phone number and registration date
  - Documents and verification info

### **4. Approve Riders**
- Click the green **"Approve"** button
- Add optional admin notes
- Confirm approval
- **Unique ID generated automatically** (e.g., `DB-2025-0001`)

### **5. Reject Applications**
- Click the red **"Reject"** button  
- **Must provide rejection reason**
- Confirm rejection
- Rider receives rejection notification

### **6. Dashboard Statistics**
- **Total Riders:** All registered users
- **Pending Approval:** Applications waiting for review
- **Approved:** Successfully approved riders  
- **Rejected:** Declined applications
- **Approval Rate:** Success percentage
- **Recent Applications:** Last 7 days activity

---

## 🔧 **Configuration**

### **Change API Endpoint**
Edit `/lib/services/admin_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:8000/api';
```

### **Update Admin Credentials**
The app connects to Django backend. Update credentials there:
```bash
python manage.py createsuperuser
```

### **Customize App Name/Icon**
- **App Name:** Edit `android/app/src/main/AndroidManifest.xml`
- **App Icon:** Replace icons in `android/app/src/main/res/mipmap-*/`

---

## 📱 **App Distribution**

### **Internal Distribution**
1. **Build APK:** `flutter build apk --release`
2. **Share APK file** via email/cloud storage
3. **Install only on admin devices**

### **Play Store (Private)**
1. Upload to **Google Play Console**
2. Set as **Internal Testing** or **Closed Testing**
3. Add admin email addresses to test group

### **Enterprise Distribution (iOS)**
1. Use **Apple Business Manager**
2. Distribute through **internal app store**
3. Control access via device management

---

## 🛡️ **Security Benefits**

✅ **Complete Separation** - Riders can't access admin features  
✅ **Dedicated Authentication** - Separate login system  
✅ **Professional Interface** - Enterprise-grade dashboard  
✅ **Secure Distribution** - Install only on admin devices  
✅ **Independent Updates** - Update admin features separately  
✅ **Audit Trail** - All admin actions tracked with timestamps  
✅ **Access Control** - Only authorized personnel have the app  

---

## 🔄 **Maintenance**

### **Update the App**
```bash
cd /home/katende/Desktop/DigitalBoda/digitalboda_admin
flutter pub get
flutter build apk --release
```
Distribute new APK to admin devices.

### **Monitor Usage**
- Check Django admin logs for API usage
- Monitor successful/failed login attempts
- Track approval/rejection patterns

### **Backup Data**
- Regular Django database backups
- Admin action logs preservation
- User upload files backup

---

## 📞 **Support**

For technical support or admin app issues:
1. Check Django backend server status
2. Verify network connectivity  
3. Review admin credentials
4. Check API endpoints accessibility

---

**🏍️ DigitalBoda Admin App - Professional Rider Management Solution**