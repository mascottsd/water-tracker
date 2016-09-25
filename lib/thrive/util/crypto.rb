# A helper utility for encrypting and decypting strings. Leverages the
# secret key as the crypto key
class Track::Util::Crypto

  def self.cipher mode, key, data
    cipher = OpenSSL::Cipher::Cipher.new('bf-cbc').send(mode)
    cipher.key = Digest::SHA256.digest(key)
    cipher.update(data) << cipher.final
  end # def self.cipher

  def self.encrypt string
    key = Rails.application.secrets.secret_key_base
    encrypted = cipher :encrypt, key, string
    Base64.encode64(encrypted).encode('utf-8')
  end # def self.encrypt

end # class Track::Util::Crypto
