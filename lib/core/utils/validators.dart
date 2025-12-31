/// Form validators for the app
class Validators {
  Validators._();

  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    
    return null;
  }

  /// Validate password requirements
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    
    if (value.length > 50) {
      return 'Password maksimal 50 karakter';
    }
    
    return null;
  }

  /// Validate password confirmation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    
    if (value != password) {
      return 'Password tidak cocok';
    }
    
    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    
    // Remove spaces and dashes for validation
    final cleanPhone = value.replaceAll(RegExp(r'[\s-]'), '');
    
    // Indonesian phone number format
    final phoneRegex = RegExp(r'^(\+62|62|0)[0-9]{9,12}$');
    
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Format nomor telepon tidak valid';
    }
    
    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  /// Validate name
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    
    if (value.length < 2) {
      return 'Nama minimal 2 karakter';
    }
    
    if (value.length > 100) {
      return 'Nama maksimal 100 karakter';
    }
    
    return null;
  }

  /// Validate price
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Harga tidak boleh kosong';
    }
    
    final price = double.tryParse(value.replaceAll(RegExp(r'[^\d.]'), ''));
    
    if (price == null || price <= 0) {
      return 'Harga harus lebih dari 0';
    }
    
    return null;
  }

  /// Validate stock quantity
  static String? validateStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'Stok tidak boleh kosong';
    }
    
    final stock = int.tryParse(value);
    
    if (stock == null || stock < 0) {
      return 'Stok harus berupa angka positif';
    }
    
    return null;
  }

  /// Validate address
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Alamat tidak boleh kosong';
    }
    
    if (value.length < 10) {
      return 'Alamat minimal 10 karakter';
    }
    
    if (value.length > 500) {
      return 'Alamat maksimal 500 karakter';
    }
    
    return null;
  }

  /// Validate product description
  static String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Deskripsi tidak boleh kosong';
    }
    
    if (value.length < 20) {
      return 'Deskripsi minimal 20 karakter';
    }
    
    if (value.length > 2000) {
      return 'Deskripsi maksimal 2000 karakter';
    }
    
    return null;
  }
}
