create table Product (product_id serial primary key,product_name varchar(255),product_categories varchar(255)
					 ,product_price float8 not NULL, product_desc varchar(255));


create table Category(category_id serial primary key,category_name varchar(255) not null);

alter table Product add constraint fk_categoty_id foreign key (category_id) references Category(category_id);
alter table Product drop product_categories;
alter table Product add column category_id int;



create table Roles (role_id serial primary key,role_name varchar(255) not null);


create table Users (user_id serial primary key,first_name varchar(255) not null,last_name varchar(255),role_id int not null, constraint role_customer_id foreign key(role_id) references Roles(role_id)
				  );
drop table Users;

create table Orders (order_id serial primary key, user_id int not null,order_date date,order_status bool,
					constraint fk_user_id foreign key (user_id) references Users(user_id) 
					)
create table Order_items(order_id int not null,product_id int not null,constraint fk_order_id foreign key (order_id) references
						Orders(order_id),constraint fk_product_id foreign key (product_id) references
						Product(product_id));
						
alter table Order_items rename to Innvoice;



select * from Roles;
select * from Category;
select * from Product;

insert into Roles(role_name) values ('Admin');
insert into Roles(role_name) values ('Customer');

insert into Category(category_name) values ('Eyewear'),('Watches'),('Shoes'),('Gadgets');

insert into Product(product_name,product_price,product_desc,category_id) values ('Aviators',1999,'very stylish',1);
insert into Product(product_name,product_price,product_desc,category_id) values ('Super Fibre',2199,'cool looking',2);
insert into Product(product_name,product_price,product_desc,category_id) values ('Liteforce Sneakers',3799,'light weight',3);
insert into Product(product_name,product_price,product_desc,category_id) values ('Iphone 13',87999,'very expensive',4);


-- view to see orders placed in last 6 months;



