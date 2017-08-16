CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  body TEXT NOT NULL,
  parent_id INTEGER,
  user_id TEXT NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id)
);

CREATE TABLE question_likes (
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ("AJ", "Ansel"),
  ("David", "Banks");

INSERT INTO
  questions (title, body, user_id)
VALUES
  ("Atom trouble", "Atom is fucked up man", 1),
  ("Terminal trouble", "Terminal is fucked up bro", 2);

INSERT INTO
  question_follows (user_id, question_id)
VALUES
  (1,2),
  (1,1),
  (2,1),
  (2,2);

INSERT INTO
  replies (question_id, body, user_id, parent_id)
VALUES
  (1, "Just unplug it", 2, NULL),
  (2, "Break the computer", 1, NULL),
  (2, "That didn't help", 2, 2);

INSERT INTO
  question_likes (user_id, question_id)
VALUES
  (1,1),
  (1,2),
  (2,1),
  (2,2);
