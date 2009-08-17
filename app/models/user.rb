class User < ActiveRecord::Base
  has_many :accounts
  has_many :incomes
  
	require 'digest/md5'
	def password=(value)
		self.password_hash = User::hash_value(value)
	end
	
	
	
	private
	
	def self.authenticate(name, pass)
		user = User.find_by_username(name)
		if(user && self.hash_value(pass) == user.password_hash)
			return true
		else
			return false
		end
	end
	
	def self.hash_value(value)
		return Digest::MD5.hexdigest(value)
	end
end
