create table Product (product_id serial primary key,product_name varchar(255),product_categories varchar(255)
					                             ,product_price float8 not NULL, product_desc varchar(255));


create table Category(category_id serial primary key,category_name varchar(255) not null);

alter table Product add constraint fk_categoty_id foreign key (category_id) references Category(category_id);

alter table Product drop product_categories;

alter table Product add column category_id int;



create table Roles (role_id serial primary key,role_name varchar(255) not null);


create table Users (user_id serial primary key,first_name varchar(255) not null,last_name varchar(255),role_id int not null, 
				                               constraint role_customer_id foreign key(role_id) references Roles(role_id) );
											   
											   
drop table Users;

create table Orders (order_id serial primary key, user_id int not null,order_date date,order_status bool,
					             constraint fk_user_id foreign key (user_id) references Users(user_id) );
					
					
create table Order_items(order_id int not null,product_id int not null,constraint fk_order_id foreign key (order_id) references
						      Orders(order_id),constraint fk_product_id foreign key (product_id) references Product(product_id));
							  
						
alter table Order_items rename to Innvoice;



select * from Roles;
select * from Category;
select * from Product;
select * from Users;

insert into Users(first_name,last_name,role_id) values ('Rajesh','Kumar',2),('Darshan','Jain',2);

insert into Roles(role_name) values ('Admin');
insert into Roles(role_name) values ('Customer');

insert into Category(category_name) values ('Eyewear'),('Watches'),('Shoes'),('Gadgets');

insert into Product(product_name,product_price,product_desc,category_id) values ('Aviators',1999,'very stylish',1);
insert into Product(product_name,product_price,product_desc,category_id) values ('Super Fibre',2199,'cool looking',2);
insert into Product(product_name,product_price,product_desc,category_id) values ('Liteforce Sneakers',3799,'light weight',3);
insert into Product(product_name,product_price,product_desc,category_id) values ('Iphone 13',87999,'very expensive',4);


-- view to see orders placed in last 6 months;

create view last_six_months_orders as
select Product.product_name as Product_Name,Product_price as Price,Orders.order_date as Date_of_Purchase
from Orders inner join Innvoice on Orders.order_id=Innvoice.order_id
inner join Product on Innvoice.product_id=Product.product_id
where order_date <= (current_date - interval '180 day') and Orders.user_id='1';

-- here we will supply user id to find last six month orders detail.


-- creating a trigger which got executed when an entry is inserted into Orders_table;

create or replace function insert_items_of_order()
returns trigger
language PLPGSQL
as
$$
  declare 
  product_id int;
  list  int[];
 begin
  list := string_to_array(TG_ARGV[0]);
  foreach product_id in array list
  
  loop
  insert into Innvoice(order_id,product_id) values (new.order_id,product_id);
  end loop;
  
  return new;
 end;
$$

create trigger trigger_insert_items_in_innvoice after insert on Orders for each row
execute procedure insert_items_of_order('list');




select * from Innvoice;
select * from last_six_months_orders;
drop view last_six_months_orders;


DROP FUNCTION insert_items_of_order();










-- logging table for storing before and after value
create table logging_t_history (
        id             serial,
        tstamp         timestamp default now(),
        schemaname     text,
        tabname        text,
        operation      text,
        who            text default current_user,
        new_val        json,
        old_val        json
);

-- procedure for logging data
create or replace function change_trigger() returns trigger as $$
       begin
         if TG_OP = 'INSERT'
         then insert into logging_t_history (
                tabname, schemaname, operation, new_val
              ) values (
                TG_RELNAME, TG_TABLE_SCHEMA, TG_OP, row_to_json(NEW)
              );
           return new;
         elsif  TG_OP = 'UPDATE'
         then
           insert into logging_t_history (
             tabname, schemaname, operation, new_val, old_val
           )
           values (TG_RELNAME, TG_TABLE_SCHEMA, TG_OP, row_to_json(NEW), row_to_json(OLD));
           return new;
         elsif TG_OP = 'DELETE'
         then
           insert into logging_t_history
             (tabname, schemaname, operation, old_val)
             values (
               TG_RELNAME, TG_TABLE_SCHEMA, TG_OP, row_to_json(OLD)
             );
             return old;
         end if;
       end;
$$ language 'plpgsql' security definer;

create trigger t before insert or update or delete on Product
        for each row execute procedure change_trigger();
		
select * from Product;
update Product set product_name = 'raaz' where product_id=1;
select * from logging_t_history;


