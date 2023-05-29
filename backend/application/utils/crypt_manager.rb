require 'openssl'

class CryptManager
  def encrypt(plaintext, key)
    cipher = OpenSSL::Cipher.new('AES-128-CBC')
    cipher.encrypt
    cipher.key = key
    iv = cipher.random_iv
    encrypted = cipher.update(plaintext) + cipher.final
    return iv + encrypted
  end

  def decrypt(ciphertext, key)
    cipher = OpenSSL::Cipher.new('AES-128-CBC')
    cipher.decrypt
    cipher.key = key
    iv = ciphertext.slice!(0, cipher.iv_len)
    cipher.iv = iv
    decrypted = cipher.update(ciphertext) + cipher.final
    return decrypted.force_encoding('UTF-8')
  end

  def derive_aes_key(password, salt, iterations = 500000, key_length = 16)
    digest = OpenSSL::Digest.new('SHA256')
    key = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, iterations, key_length, digest)
    return key
  end
end