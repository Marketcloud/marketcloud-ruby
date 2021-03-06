require_relative 'request'
require 'faraday'
require 'json'

module Marketcloud
	class Address < Request
		attr_accessor :id, :full_name, :user_id, :email, :country, :state, :city, :address1,
									:address2, :postal_code, :phone_number, :alternate_phone_number,
									:vat

		def initialize(attributes)
			@id = attributes['id']
			@full_name = attributes['full_name']
			@user_id = attributes['user_id']
			@email = attributes['email']
			@country = attributes['country']
			@state = attributes['state']
			@city = attributes['city']
			@address1 = attributes['address1']
			@address2 = attributes['address2']
			@postal_code = attributes['postal_code']
			@phone_number = attributes['phone_number']
			@alternate_phone_number = attributes['alternate_phone_number']
			@vat = attributes['vat']
		end

		def update_fields(attributes)
			self.id = attributes['id']
			self.full_name = attributes['full_name']
			self.user_id = attributes['user_id']
			self.email = attributes['email']
			self.country = attributes['country']
			self.state = attributes['state']
			self.city = attributes['city']
			self.address1 = attributes['address1']
			self.address2 = attributes['address2']
			self.postal_code = attributes['postal_code']
			self.phone_number = attributes['phone_number']
			self.alternate_phone_number = attributes['alternate_phone_number']
			self.vat = attributes['vat']
			true
		end

		def self.cache_me?
			false
		end

		# Find an address by ID
		# @param id [Integer] the ID of the address
		# @return an Address or nil
		def self.find(id)
			address = perform_request api_url("addresses/#{id}"), :get, nil, true

			if address
				new address['data']
			else
				nil
			end
		end

		# Find all the addresses belonging to a user
		# @param user_id [Integer] the user ID
		# @return an array of Addresses or nil
		def self.find_by_user(user_id)
			addresses = perform_request api_url("addresses", { user_id: user_id }), :get, nil, true

			if addresses
				addresses['data'].map { |a| new(a) }
			else
				nil
			end
		end

		# Find an address by ID and checks it belongs to the user
		# @param id [Integer] the address ID
		# @param user_id [Integer] the user ID
		# @return an Address or nil
		def self.find_and_check_user(id, user_id)
			address = perform_request api_url("addresses/#{id}"), :get, nil, true

			if address
				addr = new address['data']
				if addr.user_id != user_id
					raise Marketcloud::AddressNotFound.new("Address #{addr.id} not belonging to user #{user_id}")
				end
				addr
			else
				nil
			end
		end

		# Create a new address
		# @param address [Address] the new address
		# @return the newly created address
		def self.create(address)
			address = perform_request api_url("addresses", {}), :post, address, true

			if address
				new address['data']
			else
				nil
			end
		end

		# Delete an address
		# @param address_ID [Integer] the address to be deleted
		# @return true in case of success
		def self.delete(id)
			success = perform_request api_url("addresses/#{id}", {}), :delete, nil, true

			if success
				true
			else
				false
			end
		end

		# Updates the current address (! modifies object!)
		# @param address [Address] the updated addresss
		# @return true for success, false otherwise
		def update!(address)
			address = Address.perform_request Address.api_url("addresses/#{self.id}", {}), :put, address, true

			if address
				update_fields(address['data'])
			else
				false
			end
		end
	end
end
