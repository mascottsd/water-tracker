Tenant.create(
    tenant_name: 'iTrack',
    subdomain: 'app',
    desktop: 'desktop.jpg',
    login: 'login.png',
    logo: 'logo.png'
);

# User.create(user_id: 'F01235D0287011E6AEA7123HEF2B3BD8', email: 'aaron@buildit.io', password: '1!Biking', first_name: 'Aaron', last_name: 'Henderson', gender: 'male', confirmed_at: DateTime.now, is_admin: true, subdomain: 'app')

User.create( [{
	user_id: 'F01235D0287011E6AEA7123HEF2B3BD8',
	email: 'aaron@buildit.io',
	password: '1!Biking',
	first_name: 'Aaron',
	last_name: 'Henderson',
	gender: 'male',
	confirmed_at: DateTime.now,
	is_admin: true,
	subdomain: 'app'
},{
	user_id: 'F02755D384123E6AEA7ATOHEF2B3BD83',
	email: 'mascottsd@gmail.com',
	password: "1!Biking",
	first_name: 'Mark',
	last_name: 'Scott',
	gender: 'male',
	confirmed_at: DateTime.now,
	is_admin: false,
	subdomain: 'app'
}]);

Admin.create([{
  admin_id: "F99345D0287011E6AEA7A8667F2B3BC9",
	email: 'mascottsd@gmail.com',
	password: "1!Biking",
  first_name: "Mark",
  last_name: "Scott",
  confirmed_at: DateTime.now
}]);
