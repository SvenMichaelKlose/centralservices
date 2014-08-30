DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id INT PRIMARY KEY AUTO_INCREMENT,
	alias VARCHAR(255) UNIQUE KEY,
	password VARCHAR(32) NOT NULL,
	email VARCHAR(255) NOT NULL,
	f_registered BOOLEAN NOT NULL DEFAULT 0,
	t_registered DATETIME
);

INSERT INTO users (alias, password, email, f_registered, t_registered)
VALUES ('admin', md5('admin'), 'webmaster@localhost', TRUE, '2012-03-01 16:45:00');
