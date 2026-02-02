--create database Booking_system

create table users (
    id int identity primary key,
    fname varchar(50) not null,
    lname varchar(50) not null,
    email varchar(100) not null unique,
    phone varchar(20) unique,
    gender char(1) check (gender in ('m','f')),
    city varchar(50),
    description varchar(200),
    password varchar(255) not null,
    role varchar(20) check (role in ('admin','owner','customer')),
    createdate datetime default getdate(),
    proimage varchar(200)
);

create table apartments (
    id int identity primary key,
    apartment_type varchar(50),
    capacity int check (capacity > 0),
    state varchar(20) check (state in ('available','unavailable')),
    description varchar(200),
    createdate datetime default getdate(),
    city varchar(50),
    street varchar(50),
    anum varchar(20),
    building varchar(20),
    user_id int not null,

    constraint fk_apartment_user
    foreign key (user_id) references users(id)
);

create table apartment_images (
    id int identity primary key,
    apartment_id int not null,
    image varchar(200) not null,

    constraint fk_image_apartment
    foreign key (apartment_id) references apartments(id)
    on delete cascade
);

create table rentable_units (
    id int identity primary key,
    createdate datetime default getdate(),
    status varchar(20) check (status in ('available','reserved')),
    type varchar(50),
    capacity int check (capacity > 0),
    rent_rate decimal(10,2) not null,
    apartment_id int not null,

    constraint fk_unit_apartment
    foreign key (apartment_id) references apartments(id)
);

create table bookings (
    id int identity primary key,
    user_id int not null,
    unit_id int not null,
    createdate datetime default getdate(),
    totalprice decimal(10,2) not null,
    status varchar(20) check (status in ('pending','confirmed','cancelled')),
    startdate date not null,
    enddate date not null,

    constraint chk_booking_dates
    check (startdate < enddate),

    constraint fk_booking_user
    foreign key (user_id) references users(id),

    constraint fk_booking_unit
    foreign key (unit_id) references rentable_units(id)
);

create table payments (
    id int identity primary key,
    pmethod varchar(20) check (pmethod in ('cash','card','paypal')),
    amount decimal(10,2) not null,
    paidate datetime,
    status varchar(20) check (status in ('paid','pending','failed')),
    createdate datetime default getdate(),
    booking_id int not null,

    constraint fk_payment_booking
    foreign key (booking_id) references bookings(id)
);


create table reviews (
    id int identity primary key,
    comment varchar(300),
    rate int check (rate between 1 and 5),
    createdate datetime default getdate(),
    user_id int not null,
    apartment_id int not null,

    constraint fk_review_user
    foreign key (user_id) references users(id),

    constraint fk_review_apartment
    foreign key (apartment_id) references apartments(id)
);


insert into users (fname, lname, email, phone, gender, city, password, role)
values
('ahmed', 'ali', 'ahmed@gmail.com', '01011111111', 'm', 'cairo', 'hashed1', 'owner'),
('mohamed', 'hassan', 'mohamed@gmail.com', '01022222222', 'm', 'giza', 'hashed2', 'owner'),
('sara', 'ibrahim', 'sara@gmail.com', '01033333333', 'f', 'alex', 'hashed3', 'customer'),
('noor', 'adel', 'noor@gmail.com', '01044444444', 'f', 'cairo', 'hashed4', 'customer');


insert into apartments (apartment_type, capacity, state, description, city, street, anum, building, user_id)
values
('studio', 2, 'available', 'modern studio near metro', 'cairo', 'tahrir', '10', 'a', 1),
('family', 5, 'available', 'large family apartment', 'giza', 'dokki', '25', 'b', 2);


insert into apartment_images (apartment_id, image)
values
(1, 'img1.jpg'),
(1, 'img2.jpg'),
(2, 'img3.jpg');


insert into rentable_units (status, type, capacity, rent_rate, apartment_id)
values
('available', 'room', 2, 500.00, 1),
('available', 'full apartment', 5, 1500.00, 2);


insert into bookings (user_id, unit_id, totalprice, status, startdate, enddate)
values
(3, 1, 1500.00, 'confirmed', '2026-02-01', '2026-02-04'),
(4, 2, 3000.00, 'pending', '2026-02-10', '2026-02-12');
insert into payments (pmethod, amount, paidate, status, booking_id)
values
('card', 1500.00, getdate(), 'paid', 1),
('cash', 3000.00, null, 'pending', 2);


insert into reviews (comment, rate, user_id, apartment_id)
values
('very clean and comfortable', 5, 3, 1),
('good location but noisy', 4, 4, 2);


update bookings
set status = 'cancelled'
where id = 2;


