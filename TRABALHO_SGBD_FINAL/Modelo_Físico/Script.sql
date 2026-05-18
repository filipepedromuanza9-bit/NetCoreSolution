-- SISTEMA DE GESTÃO DE BIBLIOTECA UNIVERSITÁRIA
DROP DATABASE IF EXISTS BibliotecaUniversitaria;
CREATE DATABASE BibliotecaUniversitaria
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE BibliotecaUniversitaria;

-- Desativar verificação de FK durante criação das tabelas
SET FOREIGN_KEY_CHECKS = 0;

-- SECÇÃO 1: DDL — CRIAÇÃO DAS TABELAS (3FN)
-- Tabela: Autores  -- Sem dependências externas → criada primeiro
CREATE TABLE Autores (
Id_Autor INT NOT NULL AUTO_INCREMENT,
Nome VARCHAR(150) NOT NULL,
Nacionalidade VARCHAR(100) NOT NULL,
Data_Nasc DATE NOT NULL,
CONSTRAINT PK_Autores PRIMARY KEY (Id_Autor)
) ENGINE=InnoDB COMMENT='Regista os autores dos livros do acervo.';

-- Tabela: Editora
-- Sem dependências externas → criada antes de Livro
CREATE TABLE Editora (
Id_Editora INT NOT NULL AUTO_INCREMENT,
Nome_Editora VARCHAR(150) NOT NULL,
Cidade VARCHAR(100) NOT NULL,
Pais VARCHAR(100) NOT NULL,
CONSTRAINT PK_Editora PRIMARY KEY (Id_Editora)
) ENGINE=InnoDB COMMENT='Regista as editoras dos livros.';

-- Tabela: Livro
-- Depende de Editora → criada depois de Editora
CREATE TABLE Livro (
Id_Livro INT NOT NULL AUTO_INCREMENT,
Titulo VARCHAR(255) NOT NULL,
ISBN VARCHAR(20) NOT NULL,
Ano_Publicacao YEAR NOT NULL,
Edicao VARCHAR(50) NOT NULL DEFAULT '1a Edicao',
Categoria VARCHAR(100) NOT NULL,
Qtd_Total INT NOT NULL CHECK (Qtd_Total >= 0),
Qtd_Disponivel INT NOT NULL DEFAULT 0 CHECK (Qtd_Disponivel >= 0),
Id_Editora INT NOT NULL,
CONSTRAINT PK_Livro PRIMARY KEY (Id_Livro),
CONSTRAINT UQ_Livro_ISBN UNIQUE (ISBN),
CONSTRAINT FK_Livro_Editora
FOREIGN KEY (Id_Editora) REFERENCES Editora (Id_Editora)
ON DELETE RESTRICT ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Acervo de livros da biblioteca.';

-- Tabela: Livro_Autor (associação N:N entre Livro e Autores)
CREATE TABLE Livro_Autor (
Id_Livro INT NOT NULL,
Id_Autor INT NOT NULL,
CONSTRAINT PK_Livro_Autor PRIMARY KEY (Id_Livro, Id_Autor),
CONSTRAINT FK_LivroAutor_Livro
FOREIGN KEY (Id_Livro) REFERENCES Livro (Id_Livro)
ON DELETE RESTRICT ON UPDATE NO ACTION,
CONSTRAINT FK_LivroAutor_Autor
FOREIGN KEY (Id_Autor) REFERENCES Autores (Id_Autor)
ON DELETE RESTRICT ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Relacionamento N:N entre Livros e Autores.';

-- Tabela: Utilizadores
CREATE TABLE Utilizadores (
Id_Utilizador INT NOT NULL AUTO_INCREMENT,
Nome VARCHAR(150) NOT NULL,
Email VARCHAR(200) NOT NULL,
Telefone VARCHAR(20) NULL,
Genero ENUM('M','F','Outro') NOT NULL,
Data_Registo DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
Tipo_Utilizador ENUM('Aluno','Professor','Funcionario') NOT NULL,
CONSTRAINT PK_Utilizadores PRIMARY KEY (Id_Utilizador),
CONSTRAINT UQ_Utilizadores_Email UNIQUE (Email)
) ENGINE=InnoDB COMMENT='Utilizadores da biblioteca (alunos, professores, funcionários).';

-- Tabela: Emprestimo
-- Depende de Utilizadores e Livro
CREATE TABLE Emprestimo (
Id_Emprestimo INT NOT NULL AUTO_INCREMENT,
Id_Utilizador INT NOT NULL,
Id_Livro INT NOT NULL,
Data_Emprestimo DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
Data_Devolucao_Prevista DATE NOT NULL,
Data_Devolucao_Real DATE NULL,
Estado ENUM('Emprestado','Devolvido','Atrasado') NOT NULL DEFAULT 'Emprestado',
CONSTRAINT PK_Emprestimo PRIMARY KEY (Id_Emprestimo),
CONSTRAINT FK_Emprestimo_Utilizador
FOREIGN KEY (Id_Utilizador) REFERENCES Utilizadores (Id_Utilizador)
ON DELETE RESTRICT ON UPDATE NO ACTION,
CONSTRAINT FK_Emprestimo_Livro
FOREIGN KEY (Id_Livro) REFERENCES Livro (Id_Livro)
ON DELETE RESTRICT ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Registo de todos os empréstimos.';

-- Tabela: Reservas
-- Depende de Utilizadores e Livro
CREATE TABLE Reservas (
Id_Reserva INT NOT NULL AUTO_INCREMENT,
Id_Utilizador INT NOT NULL,
Id_Livro INT NOT NULL,
Data_Reserva DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
Estado ENUM('Ativa','Cancelada','Concluida') NOT NULL DEFAULT 'Ativa',
CONSTRAINT PK_Reservas PRIMARY KEY (Id_Reserva),
CONSTRAINT FK_Reservas_Utilizador
FOREIGN KEY (Id_Utilizador) REFERENCES Utilizadores (Id_Utilizador)
ON DELETE RESTRICT ON UPDATE NO ACTION,
CONSTRAINT FK_Reservas_Livro
FOREIGN KEY (Id_Livro) REFERENCES Livro (Id_Livro)
ON DELETE RESTRICT ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Reservas de livros pelos utilizadores.';

-- Tabela: Multas
-- Depende de Utilizadores e Emprestimo
CREATE TABLE Multas (
Id_Multa INT NOT NULL AUTO_INCREMENT,
Id_Utilizador INT NOT NULL,
Id_Emprestimo INT NOT NULL,
Valor DECIMAL(10,2) NOT NULL CHECK (Valor > 0),
Data_Multa DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
Estado ENUM('Pendente','Paga') NOT NULL DEFAULT 'Pendente',
CONSTRAINT PK_Multas PRIMARY KEY (Id_Multa),
CONSTRAINT FK_Multas_Utilizador
FOREIGN KEY (Id_Utilizador) REFERENCES Utilizadores (Id_Utilizador)
ON DELETE RESTRICT ON UPDATE NO ACTION,
CONSTRAINT FK_Multas_Emprestimo
FOREIGN KEY (Id_Emprestimo) REFERENCES Emprestimo (Id_Emprestimo)
ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='Multas geradas por atrasos na devolução.';

-- Reativar verificação de FK
SET FOREIGN_KEY_CHECKS = 1;

-- SECÇÃO 2: VIEWS
-- Livros disponíveis para empréstimo
CREATE OR REPLACE VIEW VW_LivrosDisponiveis AS
SELECT
l.Id_Livro,
l.Titulo,
l.ISBN,
l.Ano_Publicacao,
l.Edicao,
l.Categoria,
l.Qtd_Disponivel,
e.Nome_Editora,
GROUP_CONCAT(a.Nome ORDER BY a.Nome SEPARATOR ', ') AS Autores
FROM Livro l
JOIN Editora e ON l.Id_Editora = e.Id_Editora
LEFT JOIN Livro_Autor la ON l.Id_Livro = la.Id_Livro
LEFT JOIN Autores a ON la.Id_Autor = a.Id_Autor
WHERE l.Qtd_Disponivel > 0
GROUP BY l.Id_Livro, l.Titulo, l.ISBN, l.Ano_Publicacao, l.Edicao,
l.Categoria, l.Qtd_Disponivel, e.Nome_Editora;

-- VIEW: Empréstimos ativos com detalhes
CREATE OR REPLACE VIEW VW_EmprestimosAtivos AS
SELECT
em.Id_Emprestimo,
u.Id_Utilizador,
u.Nome AS Nome_Utilizador,
u.Tipo_Utilizador,
l.Id_Livro,
l.Titulo AS Titulo_Livro,
l.ISBN,
em.Data_Emprestimo,
em.Data_Devolucao_Prevista,
DATEDIFF(CURRENT_DATE, em.Data_Devolucao_Prevista) AS Dias_Atraso,
em.Estado
FROM Emprestimo em
JOIN Utilizadores u ON em.Id_Utilizador = u.Id_Utilizador
JOIN Livro l ON em.Id_Livro = l.Id_Livro
WHERE em.Estado IN ('Emprestado','Atrasado');

-- VIEW: Utilizadores com multas pendentes
CREATE OR REPLACE VIEW VW_UtilizadoresMultasPendentes AS
SELECT
u.Id_Utilizador,
u.Nome,
u.Email,
u.Tipo_Utilizador,
COUNT(m.Id_Multa) AS Num_Multas,
SUM(m.Valor) AS Total_Divida
FROM Utilizadores u
JOIN Multas m ON u.Id_Utilizador = m.Id_Utilizador
WHERE m.Estado = 'Pendente'
GROUP BY u.Id_Utilizador, u.Nome, u.Email, u.Tipo_Utilizador;

-- VIEW: Reservas ativas
CREATE OR REPLACE VIEW VW_ReservasAtivas AS
SELECT
r.Id_Reserva,
u.Nome AS Nome_Utilizador,
l.Titulo AS Titulo_Livro,
l.ISBN,
r.Data_Reserva,
r.Estado
FROM Reservas r
JOIN Utilizadores u ON r.Id_Utilizador = u.Id_Utilizador
JOIN Livro l ON r.Id_Livro = l.Id_Livro
WHERE r.Estado = 'Ativa';

-- SECÇÃO 3: STORED PROCEDURES E FUNCTIONS
DELIMITER $$

-- FUNCTION: Calcula prazo de devolução conforme TipoUtilizador
CREATE FUNCTION FN_PrazoDevolucao(p_Tipo ENUM('Aluno','Professor','Funcionario'))
RETURNS INT DETERMINISTIC
BEGIN
RETURN CASE p_Tipo
WHEN 'Professor'   THEN 30
WHEN 'Funcionario' THEN 20
ELSE                    15  -- Aluno
END;
END$$

-- FUNCTION: Calcula valor da multa (0,50 AOA por dia de atraso)
CREATE FUNCTION FN_CalcularMulta(p_DataPrevista DATE, p_DataReal DATE)
RETURNS DECIMAL(10,2) DETERMINISTIC
BEGIN
DECLARE v_Dias INT;
SET v_Dias = DATEDIFF(p_DataReal, p_DataPrevista);
IF v_Dias <= 0 THEN
RETURN 0.00;
END IF;
RETURN v_Dias * 0.50;
END$$

-- PROCEDURE: Registar novo empréstimo
CREATE PROCEDURE SP_RegistarEmprestimo(
IN  p_IdUtilizador INT,
IN  p_IdLivro      INT,
OUT p_Mensagem     VARCHAR(200)
)
BEGIN
DECLARE v_QtdDisp         INT DEFAULT 0;
DECLARE v_NumEmprestimos  INT DEFAULT 0;
DECLARE v_MultasPendentes INT DEFAULT 0;
DECLARE v_JaTemLivro      INT DEFAULT 0;
DECLARE v_TipoUtil        ENUM('Aluno','Professor','Funcionario');
DECLARE v_Prazo           INT;
DECLARE v_DataPrevista    DATE;

-- Verificar multas pendentes
SELECT COUNT(*) INTO v_MultasPendentes
FROM Multas
WHERE Id_Utilizador = p_IdUtilizador AND Estado = 'Pendente';

IF v_MultasPendentes > 0 THEN
SET p_Mensagem = 'ERRO: Utilizador possui multas pendentes. Regularize antes de novo emprestimo.';
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_Mensagem;
END IF;

-- Verificar disponibilidade do livro
SELECT Qtd_Disponivel INTO v_QtdDisp
FROM Livro WHERE Id_Livro = p_IdLivro;

IF v_QtdDisp IS NULL THEN
SET p_Mensagem = 'ERRO: Livro nao encontrado.';
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_Mensagem;
END IF;

IF v_QtdDisp = 0 THEN
SET p_Mensagem = 'ERRO: Livro sem exemplares disponiveis.';
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_Mensagem;
END IF;

-- Verificar limite de 5 empréstimos simultâneos
SELECT COUNT(*) INTO v_NumEmprestimos
FROM Emprestimo
WHERE Id_Utilizador = p_IdUtilizador AND Estado IN ('Emprestado','Atrasado');

IF v_NumEmprestimos >= 5 THEN
SET p_Mensagem = 'ERRO: Limite de 5 emprestimos simultaneos atingido.';
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_Mensagem;
END IF;

-- Verificar se já tem este livro emprestado
SELECT COUNT(*) INTO v_JaTemLivro
FROM Emprestimo
WHERE Id_Utilizador = p_IdUtilizador
AND Id_Livro = p_IdLivro
AND Estado IN ('Emprestado','Atrasado');

IF v_JaTemLivro > 0 THEN
SET p_Mensagem = 'ERRO: Utilizador ja tem este livro emprestado.';
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_Mensagem;
END IF;

-- Calcular prazo de devolução
SELECT Tipo_Utilizador INTO v_TipoUtil
FROM Utilizadores WHERE Id_Utilizador = p_IdUtilizador;

SET v_Prazo = FN_PrazoDevolucao(v_TipoUtil);
SET v_DataPrevista = DATE_ADD(CURRENT_DATE, INTERVAL v_Prazo DAY);

-- Inserir empréstimo
INSERT INTO Emprestimo (Id_Utilizador, Id_Livro, Data_Emprestimo, Data_Devolucao_Prevista, Estado)
VALUES (p_IdUtilizador, p_IdLivro, CURRENT_DATE, v_DataPrevista, 'Emprestado');

SET p_Mensagem = CONCAT('SUCESSO: Emprestimo registado. Devolucao prevista para: ', v_DataPrevista);
END$$

-- PROCEDURE: Registar devolução
CREATE PROCEDURE SP_RegistarDevolucao(
IN  p_IdEmprestimo INT,
OUT p_Mensagem     VARCHAR(200)
)
BEGIN
DECLARE v_Estado       ENUM('Emprestado','Devolvido','Atrasado');
DECLARE v_DataPrevista DATE;
DECLARE v_IdUtilizador INT;
DECLARE v_ValorMulta   DECIMAL(10,2);

-- Obter dados do empréstimo
SELECT Estado, Data_Devolucao_Prevista, Id_Utilizador
INTO   v_Estado, v_DataPrevista, v_IdUtilizador
FROM   Emprestimo
WHERE  Id_Emprestimo = p_IdEmprestimo;

IF v_Estado IS NULL THEN
SET p_Mensagem = 'ERRO: Emprestimo nao encontrado.';
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_Mensagem;
END IF;

IF v_Estado = 'Devolvido' THEN
SET p_Mensagem = 'ERRO: Este emprestimo ja foi devolvido.';
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_Mensagem;
END IF;

-- Atualizar empréstimo
UPDATE Emprestimo
SET Data_Devolucao_Real = CURRENT_DATE,
Estado = IF(CURRENT_DATE > v_DataPrevista, 'Atrasado', 'Devolvido')
WHERE Id_Emprestimo = p_IdEmprestimo;

-- Gerar multa se atrasado
IF CURRENT_DATE > v_DataPrevista THEN
SET v_ValorMulta = FN_CalcularMulta(v_DataPrevista, CURRENT_DATE);
INSERT INTO Multas (Id_Utilizador, Id_Emprestimo, Valor, Data_Multa, Estado)
VALUES (v_IdUtilizador, p_IdEmprestimo, v_ValorMulta, CURRENT_DATE, 'Pendente');
SET p_Mensagem = CONCAT('AVISO: Devolucao com atraso. Multa gerada: ', v_ValorMulta, ' AOA.');
ELSE
SET p_Mensagem = 'SUCESSO: Livro devolvido dentro do prazo.';
END IF;
END$$

-- PROCEDURE: Fazer reserva
CREATE PROCEDURE SP_FazerReserva(
IN  p_IdUtilizador INT,
IN  p_IdLivro      INT,
OUT p_Mensagem     VARCHAR(200)
)
BEGIN
DECLARE v_MultasPendentes INT DEFAULT 0;
DECLARE v_JaTemEmprestado INT DEFAULT 0;

-- Verificar multas pendentes
SELECT COUNT(*) INTO v_MultasPendentes
FROM Multas
WHERE Id_Utilizador = p_IdUtilizador AND Estado = 'Pendente';

IF v_MultasPendentes > 0 THEN
SET p_Mensagem = 'ERRO: Utilizador com multas pendentes nao pode fazer reservas.';
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_Mensagem;
END IF;

-- Verificar se já tem o livro emprestado
SELECT COUNT(*) INTO v_JaTemEmprestado
FROM Emprestimo
WHERE Id_Utilizador = p_IdUtilizador
AND Id_Livro = p_IdLivro
AND Estado IN ('Emprestado','Atrasado');

IF v_JaTemEmprestado > 0 THEN
SET p_Mensagem = 'ERRO: Nao pode reservar um livro que ja tem emprestado.';
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_Mensagem;
END IF;

INSERT INTO Reservas (Id_Utilizador, Id_Livro, Data_Reserva, Estado)
VALUES (p_IdUtilizador, p_IdLivro, CURRENT_DATE, 'Ativa');

SET p_Mensagem = 'SUCESSO: Reserva registada com sucesso.';
END$$

-- SECÇÃO 4: TRIGGERS

-- ✅ CORRECÇÃO 1: TRG_Emprestimo_AfterInsert — removido bloco de multa inválido
-- (Data_Devolucao_Real é sempre NULL no INSERT, pelo que nunca haveria atraso aqui)
CREATE TRIGGER TRG_Emprestimo_AfterInsert
AFTER INSERT ON Emprestimo
FOR EACH ROW
BEGIN
    UPDATE Livro
    SET Qtd_Disponivel = Qtd_Disponivel - 1
    WHERE Id_Livro = NEW.Id_Livro;
END$$

-- ✅ CORRECÇÃO 2: TRG_Emprestimo_AfterUpdate — trigger que estava completamente em falta
CREATE TRIGGER TRG_Emprestimo_AfterUpdate
AFTER UPDATE ON Emprestimo
FOR EACH ROW
BEGIN
    DECLARE v_MultaExiste INT DEFAULT 0;

    IF OLD.Data_Devolucao_Real IS NULL
       AND NEW.Data_Devolucao_Real IS NOT NULL THEN

        -- Repor quantidade disponível ao devolver
        UPDATE Livro
        SET Qtd_Disponivel = Qtd_Disponivel + 1
        WHERE Id_Livro = NEW.Id_Livro;

        -- Verificar se já existe multa para este empréstimo
        SELECT COUNT(*) INTO v_MultaExiste
        FROM Multas
        WHERE Id_Emprestimo = NEW.Id_Emprestimo;

        -- Gerar multa se houve atraso e ainda não existe multa
        IF NEW.Data_Devolucao_Real > NEW.Data_Devolucao_Prevista
           AND v_MultaExiste = 0 THEN
            INSERT INTO Multas (Id_Utilizador, Id_Emprestimo, Valor, Data_Multa, Estado)
            VALUES (
                NEW.Id_Utilizador,
                NEW.Id_Emprestimo,
                FN_CalcularMulta(NEW.Data_Devolucao_Prevista, NEW.Data_Devolucao_Real),
                NEW.Data_Devolucao_Real,
                'Pendente'
            );
        END IF;

    END IF;
END$$

-- TRIGGER: Antes de inserir empréstimo → validar regras de negócio
CREATE TRIGGER TRG_Emprestimo_BeforeInsert
BEFORE INSERT ON Emprestimo
FOR EACH ROW
BEGIN
DECLARE v_QtdDisp        INT DEFAULT 0;
DECLARE v_NumEmprestimos INT DEFAULT 0;
DECLARE v_MultasPend     INT DEFAULT 0;

-- Regra: livro deve estar disponível
SELECT Qtd_Disponivel INTO v_QtdDisp
FROM Livro WHERE Id_Livro = NEW.Id_Livro;

IF v_QtdDisp = 0 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Livro sem exemplares disponiveis para emprestimo.';
END IF;

-- Regra: máximo 5 empréstimos simultâneos
SELECT COUNT(*) INTO v_NumEmprestimos
FROM Emprestimo
WHERE Id_Utilizador = NEW.Id_Utilizador
AND Estado IN ('Emprestado','Atrasado');

IF v_NumEmprestimos >= 5 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Utilizador atingiu o limite de 5 emprestimos simultaneos.';
END IF;

-- Regra: sem multas pendentes
SELECT COUNT(*) INTO v_MultasPend
FROM Multas
WHERE Id_Utilizador = NEW.Id_Utilizador AND Estado = 'Pendente';

IF v_MultasPend > 0 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Utilizador com multas pendentes nao pode fazer emprestimos.';
END IF;
END$$

-- TRIGGER: Antes de inserir reserva → validar regras de negócio
CREATE TRIGGER TRG_Reserva_BeforeInsert
BEFORE INSERT ON Reservas
FOR EACH ROW
BEGIN
DECLARE v_JaEmprestado INT DEFAULT 0;
DECLARE v_MultasPend   INT DEFAULT 0;

-- Regra: não pode reservar livro já emprestado pelo mesmo utilizador
SELECT COUNT(*) INTO v_JaEmprestado
FROM Emprestimo
WHERE Id_Utilizador = NEW.Id_Utilizador
AND Id_Livro = NEW.Id_Livro
AND Estado IN ('Emprestado','Atrasado');

IF v_JaEmprestado > 0 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Nao pode reservar um livro que ja tem emprestado.';
END IF;

-- Regra: sem multas pendentes
SELECT COUNT(*) INTO v_MultasPend
FROM Multas
WHERE Id_Utilizador = NEW.Id_Utilizador AND Estado = 'Pendente';

IF v_MultasPend > 0 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Utilizador com multas pendentes nao pode fazer reservas.';
END IF;
END$$

DELIMITER ;

-- SECÇÃO 5: DML — POPULAÇÃO DE DADOS

-- 5.1 Autores
INSERT INTO Autores (Nome, Nacionalidade, Data_Nasc) VALUES
('Pepetela',                   'Angolana',   '1941-10-29'),
('Jose Eduardo Agualusa',      'Angolana',   '1960-12-13'),
('Ondjaki',                    'Angolana',   '1977-09-29'),
('Chinua Achebe',              'Nigeriana',  '1930-11-16'),
('Chimamanda Ngozi Adichie',   'Nigeriana',  '1977-09-15'),
('Paulo Salavea',              'Portuguesa', '1965-03-18'),
('George Orwell',              'Britanica',  '1903-06-25');

-- 5.2 Editoras
INSERT INTO Editora (Nome_Editora, Cidade, Pais) VALUES
('Maianga Editora', 'Luanda',  'Angola'),
('Dom Quixote',     'Lisboa',  'Portugal'),
('Penguin Books',   'Londres', 'Reino Unido');

-- 5.3 Livros
INSERT INTO Livro (Titulo, ISBN, Ano_Publicacao, Edicao, Categoria, Qtd_Total, Qtd_Disponivel, Id_Editora) VALUES
('Mayombe',                   '978-989-660-001-1', 1980, '3ª Edição', 'Romance',         5, 3, 1),
('Yaka',                      '978-989-660-002-2', 1984, '2ª Edição', 'Romance',         4, 2, 1),
('Lueji',                     '978-989-660-003-3', 1990, '1ª Edição', 'Historia',        3, 1, 1),
('O Vendedor de Passados',    '978-972-020-001-4', 2004, '4ª Edição', 'Romance',         5, 4, 2),
('As Mulheres do meu Pai',    '978-972-020-002-5', 2007, '2ª Edição', 'Romance',         4, 3, 2),
('Milagrosa',                 '978-972-020-003-6', 2021, '1ª Edição', 'Romance',         3, 2, 2),
('Os da minha Rua',           '978-989-660-004-7', 2007, '3ª Edição', 'Contos',          5, 5, 1),
('Bom Dia Camaradas',         '978-989-660-005-8', 2000, '2ª Edição', 'Infanto-juvenil', 4, 4, 1),
('Avozinha Dezanove',         '978-989-660-006-9', 2008, '1ª Edição', 'Infanto-juvenil', 3, 3, 1),
('Things Fall Apart',         '978-0-141-18614-0', 1958, '5ª Edição', 'Romance',         6, 5, 3),
('Arrow of God',              '978-0-385-01480-0', 1964, '2ª Edição', 'Historia',        4, 2, 3),
('No Longer at Ease',         '978-0-141-18615-7', 1960, '3ª Edição', 'Romance',         4, 4, 3),
('Purple Hibiscus',           '978-1-616-20058-5', 2003, '4ª Edição', 'Romance',         5, 3, 3),
('Half of a Yellow Sun',      '978-1-400-09564-5', 2006, '3ª Edição', 'Historia',        5, 5, 3),
('Americanah',                '978-0-307-45592-5', 2013, '2ª Edição', 'Romance',         4, 2, 3),
('We Should All Be Feminists','978-1-101-91176-8', 2014, '1ª Edição', 'Sociologia',      6, 6, 3),
('Nineteen Eighty-Four',      '978-0-141-18776-5', 1949, '6ª Edição', 'Ficcao',          7, 6, 3),
('Animal Farm',               '978-0-141-18220-3', 1945, '5ª Edição', 'Ficcao',          6, 5, 3),
('A Geração da Utopia',       '978-989-660-007-0', 1992, '2ª Edição', 'Historia',        4, 2, 1),
('Predadores',                '978-989-660-008-1', 2005, '1ª Edição', 'Thriller',        3, 3, 1);

-- 5.4 Livro_Autor (associação)
INSERT INTO Livro_Autor (Id_Livro, Id_Autor) VALUES
(1,1),(2,1),(3,1),(19,1),(20,1),  -- Pepetela
(4,2),(5,2),(6,2),                -- Agualusa
(7,3),(8,3),(9,3),                -- Ondjaki
(10,4),(11,4),(12,4),             -- Achebe
(13,5),(14,5),(15,5),(16,5),      -- Adichie
(17,7),(18,7);                    -- Orwell

-- 5.5 Utilizadores (30)
INSERT INTO Utilizadores (Nome, Email, Telefone, Genero, Data_Registo, Tipo_Utilizador) VALUES
-- Alunos (15)
('Nsimba Alberto Samuel',    'nsimba.alberto@unikivi.ao',    '923164565', 'M', '2022-02-10', 'Aluno'),
('Filipe Pedro',             'FilipePedro@unikivi.ao',       '923356606', 'M', '2022-02-11', 'Aluno'),
('Guiola Andre',             'GuiolaAndre@unikivi.ao',       '939892172', 'M', '2022-03-01', 'Aluno'),
('Pedro Augusto Silva',      'pedrosilva@unikivi.ao',        '925650543', 'M', '2022-03-15', 'Aluno'),
('Joana Cristina Lopes',     'joana.lopes@unikivi.ao',       '950684573', 'F', '2022-04-05', 'Aluno'),
('Paulo Bunga',              'PauloBunga@unikivi.ao',        '923463537', 'M', '2022-04-20', 'Aluno'),
('Filomena Andreia Costa',   'filomena.costa@unikivi.ao',    '924544646', 'F', '2022-05-10', 'Aluno'),
('Antonio Dias Marques',     'antoniomarques@unikivi.ao',    '925383323', 'M', '2022-06-01', 'Aluno'),
('Sofia Marta Pinto',        'sofia.pinto@unikivi.ao',       '933262662', 'F', '2022-07-14', 'Aluno'),
('Lino Bernardo Vieira',     'lino.vieira@unikivi.ao',       '920585785', 'M', '2022-08-20', 'Aluno'),
('Rosa Conceicao Matos',     'rosa.matos@unikivi.ao',        '956667433', 'F', '2022-09-05', 'Aluno'),
('Henrique Luis Nunes',      'henrique.nunes@unikivi.ao',    '923111012', 'M', '2023-01-10', 'Aluno'),
('Catarina Isabel Brito',    'catarina.brito@unikivi.ao',    '923355600', 'F', '2023-02-14', 'Aluno'),
('Domingos Paulo Tavares',   'domingos.tavares@unikivi.ao',  '923190101', 'M', '2023-03-20', 'Aluno'),
('Lurdes Amelia Fonseca',    'lurdes.fonseca@unikivi.ao',    '922950565', 'F', '2023-04-18', 'Aluno'),
-- Professores (10)
('Prof. Juaquim Ventura',    'Juaquimventura@unikivi.ao',    '924222441', 'M', '2019-09-01', 'Professor'),
('Prof. Filipe Pedro',       'FilipePedroProf@unikivi.ao',   '924566552', 'M', '2019-09-01', 'Professor'),
('Prof. Manuel Rodrigues',   'manuel.rodrigues@unikivi.ao',  '923459304', 'M', '2020-02-01', 'Professor'),
('Prof. Carla Sousa Pereira','carla.pereira@unikivi.ao',     '926788714', 'F', '2020-02-01', 'Professor'),
('Prof. Alberto Castro',     'alberto.castro@unikivi.ao',    '939090953', 'M', '2018-09-01', 'Professor'),
('Prof. Lurdes Machado',     'lurdes.machado@unikivi.ao',    '924411234', 'F', '2018-09-01', 'Professor'),
('Prof. Rui Sampaio',        'rui.sampaio@unikivi.ao',       '923400283', 'M', '2021-03-01', 'Professor'),
('Prof. Eduarda Ferreira',   'eduarda.ferreira@unikivi.ao',  '933521133', 'F', '2021-03-01', 'Professor'),
('Prof. Nuno Cardoso',       'nuno.cardoso@unikivi.ao',      '924239554', 'M', '2017-09-01', 'Professor'),
('Prof. Graca Monteiro',     'graca.monteiro@unikivi.ao',    '935321433', 'F', '2017-09-01', 'Professor'),
-- Funcionários (5)
('Func. Jose Antunes',       'jose.antunes@unikivi.ao',      '922674361', 'M', '2015-05-10', 'Funcionario'),
('Func. Beatriz Gomes',      'beatriz.gomes@unikivi.ao',     '939573002', 'F', '2016-07-20', 'Funcionario'),
('Func. Simao Dias',         'simao.dias@unikivi.ao',        '925395703', 'M', '2017-03-15', 'Funcionario'),
('Func. Helena Araujo',      'helena.araujo@unikivi.ao',     '937300004', 'F', '2018-11-01', 'Funcionario'),
('Func. Arnaldo Macedo',     'arnaldo.macedo@unikivi.ao',    '935300957', 'M', '2020-01-10', 'Funcionario');

-- 5.6 Empréstimos
-- Para popular com dados históricos desativamos os triggers de validação
SET @SKIP_VALIDATION = 1;

-- Empréstimos devolvidos a tempo (20)
INSERT INTO Emprestimo (Id_Utilizador, Id_Livro, Data_Emprestimo, Data_Devolucao_Prevista, Data_Devolucao_Real, Estado) VALUES
(1,  1,  '2024-01-10', '2024-01-25', '2024-01-22', 'Devolvido'),
(2,  2,  '2024-01-12', '2024-01-27', '2024-01-25', 'Devolvido'),
(3,  3,  '2024-01-15', '2024-01-30', '2024-01-29', 'Devolvido'),
(4,  4,  '2024-02-01', '2024-02-16', '2024-02-14', 'Devolvido'),
(5,  5,  '2024-02-05', '2024-02-20', '2024-02-18', 'Devolvido'),
(16, 6,  '2024-02-10', '2024-03-11', '2024-03-05', 'Devolvido'),
(17, 7,  '2024-02-15', '2024-03-16', '2024-03-10', 'Devolvido'),
(18, 8,  '2024-03-01', '2024-03-31', '2024-03-28', 'Devolvido'),
(19, 9,  '2024-03-05', '2024-04-04', '2024-04-01', 'Devolvido'),
(20, 10, '2024-03-10', '2024-04-09', '2024-04-05', 'Devolvido'),
(6,  11, '2024-04-01', '2024-04-16', '2024-04-15', 'Devolvido'),
(7,  12, '2024-04-05', '2024-04-20', '2024-04-18', 'Devolvido'),
(8,  13, '2024-04-10', '2024-04-25', '2024-04-22', 'Devolvido'),
(9,  14, '2024-04-15', '2024-04-30', '2024-04-28', 'Devolvido'),
(10, 15, '2024-05-01', '2024-05-16', '2024-05-14', 'Devolvido'),
(21, 16, '2024-05-05', '2024-06-04', '2024-06-01', 'Devolvido'),
(22, 17, '2024-05-10', '2024-06-09', '2024-06-05', 'Devolvido'),
(23, 18, '2024-05-15', '2024-06-14', '2024-06-10', 'Devolvido'),
(11, 19, '2024-06-01', '2024-06-16', '2024-06-14', 'Devolvido'),
(12, 20, '2024-06-05', '2024-06-20', '2024-06-18', 'Devolvido');

-- Empréstimos atrasados — já devolvidos com atraso (15)
INSERT INTO Emprestimo (Id_Utilizador, Id_Livro, Data_Emprestimo, Data_Devolucao_Prevista, Data_Devolucao_Real, Estado) VALUES
(1,  10, '2024-07-01', '2024-07-16', '2024-07-25', 'Atrasado'),
(2,  11, '2024-07-05', '2024-07-20', '2024-08-01', 'Atrasado'),
(3,  12, '2024-07-10', '2024-07-25', '2024-08-05', 'Atrasado'),
(4,  13, '2024-07-15', '2024-07-30', '2024-08-10', 'Atrasado'),
(5,  14, '2024-07-20', '2024-08-04', '2024-08-20', 'Atrasado'),
(13, 15, '2024-08-01', '2024-08-16', '2024-09-01', 'Atrasado'),
(14, 16, '2024-08-05', '2024-09-04', '2024-09-20', 'Atrasado'),
(15, 17, '2024-08-10', '2024-08-25', '2024-09-10', 'Atrasado'),
(24, 18, '2024-08-15', '2024-09-14', '2024-10-01', 'Atrasado'),
(25, 19, '2024-08-20', '2024-09-19', '2024-10-05', 'Atrasado'),
(6,  1,  '2024-09-01', '2024-09-16', '2024-10-10', 'Atrasado'),
(7,  2,  '2024-09-05', '2024-09-20', '2024-10-15', 'Atrasado'),
(8,  3,  '2024-09-10', '2024-09-25', '2024-10-20', 'Atrasado'),
(9,  4,  '2024-09-15', '2024-09-30', '2024-10-25', 'Atrasado'),
(10, 5,  '2024-09-20', '2024-10-05', '2024-10-30', 'Atrasado');

-- Empréstimos ativos (15)
INSERT INTO Emprestimo (Id_Utilizador, Id_Livro, Data_Emprestimo, Data_Devolucao_Prevista, Data_Devolucao_Real, Estado) VALUES
(1,  6,  DATE_SUB(CURRENT_DATE, INTERVAL 5 DAY),  DATE_ADD(CURRENT_DATE, INTERVAL 10 DAY), NULL, 'Emprestado'),
(2,  7,  DATE_SUB(CURRENT_DATE, INTERVAL 3 DAY),  DATE_ADD(CURRENT_DATE, INTERVAL 12 DAY), NULL, 'Emprestado'),
(3,  8,  DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY),  DATE_ADD(CURRENT_DATE, INTERVAL 8 DAY),  NULL, 'Emprestado'),
(16, 9,  DATE_SUB(CURRENT_DATE, INTERVAL 10 DAY), DATE_ADD(CURRENT_DATE, INTERVAL 20 DAY), NULL, 'Emprestado'),
(17, 10, DATE_SUB(CURRENT_DATE, INTERVAL 15 DAY), DATE_ADD(CURRENT_DATE, INTERVAL 15 DAY), NULL, 'Emprestado'),
(18, 11, DATE_SUB(CURRENT_DATE, INTERVAL 2 DAY),  DATE_ADD(CURRENT_DATE, INTERVAL 28 DAY), NULL, 'Emprestado'),
(19, 12, DATE_SUB(CURRENT_DATE, INTERVAL 5 DAY),  DATE_ADD(CURRENT_DATE, INTERVAL 25 DAY), NULL, 'Emprestado'),
(20, 13, DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY),  DATE_ADD(CURRENT_DATE, INTERVAL 29 DAY), NULL, 'Emprestado'),
(21, 14, DATE_SUB(CURRENT_DATE, INTERVAL 8 DAY),  DATE_ADD(CURRENT_DATE, INTERVAL 22 DAY), NULL, 'Emprestado'),
(22, 15, DATE_SUB(CURRENT_DATE, INTERVAL 4 DAY),  DATE_ADD(CURRENT_DATE, INTERVAL 26 DAY), NULL, 'Emprestado'),
(11, 16, DATE_SUB(CURRENT_DATE, INTERVAL 6 DAY),  DATE_ADD(CURRENT_DATE, INTERVAL 9 DAY),  NULL, 'Emprestado'),
(12, 17, DATE_SUB(CURRENT_DATE, INTERVAL 9 DAY),  DATE_ADD(CURRENT_DATE, INTERVAL 6 DAY),  NULL, 'Emprestado'),
(26, 18, DATE_SUB(CURRENT_DATE, INTERVAL 3 DAY),  DATE_ADD(CURRENT_DATE, INTERVAL 17 DAY), NULL, 'Emprestado'),
(27, 19, DATE_SUB(CURRENT_DATE, INTERVAL 11 DAY), DATE_ADD(CURRENT_DATE, INTERVAL 9 DAY),  NULL, 'Emprestado'),
(28, 20, DATE_SUB(CURRENT_DATE, INTERVAL 2 DAY),  DATE_ADD(CURRENT_DATE, INTERVAL 18 DAY), NULL, 'Emprestado');

-- Verificação de Qtd_Disponivel
SELECT Id_Livro, Qtd_Disponivel FROM Livro;

-- 5.7 Multas — geradas pelos empréstimos atrasados
INSERT INTO Multas (Id_Utilizador, Id_Emprestimo, Valor, Data_Multa, Estado) VALUES
(1,  21, FN_CalcularMulta('2024-07-16', '2024-07-25'), '2024-07-25', 'Pendente'),
(2,  22, FN_CalcularMulta('2024-07-20', '2024-08-01'), '2024-08-01', 'Paga'),
(3,  23, FN_CalcularMulta('2024-07-25', '2024-08-05'), '2024-08-05', 'Pendente'),
(4,  24, FN_CalcularMulta('2024-07-30', '2024-08-10'), '2024-08-10', 'Pendente'),
(5,  25, FN_CalcularMulta('2024-08-04', '2024-08-20'), '2024-08-20', 'Paga'),
(13, 26, FN_CalcularMulta('2024-08-16', '2024-09-01'), '2024-09-01', 'Pendente'),
(14, 27, FN_CalcularMulta('2024-09-04', '2024-09-20'), '2024-09-20', 'Pendente');

-- 5.8 Reservas
INSERT INTO Reservas (Id_Utilizador, Id_Livro, Data_Reserva, Estado) VALUES
(6,  1,  DATE_SUB(CURRENT_DATE, INTERVAL 2 DAY), 'Ativa'),
(7,  1,  DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY), 'Ativa'),
(8,  2,  CURRENT_DATE,                           'Ativa'),
(9,  3,  DATE_SUB(CURRENT_DATE, INTERVAL 5 DAY), 'Ativa'),
(10, 4,  DATE_SUB(CURRENT_DATE, INTERVAL 3 DAY), 'Ativa'),
(11, 5,  DATE_SUB(CURRENT_DATE, INTERVAL 4 DAY), 'Ativa'),
(12, 6,  DATE_SUB(CURRENT_DATE, INTERVAL 2 DAY), 'Cancelada'),
(13, 7,  DATE_SUB(CURRENT_DATE, INTERVAL 7 DAY), 'Concluida'),
(14, 8,  DATE_SUB(CURRENT_DATE, INTERVAL 6 DAY), 'Ativa'),
(15, 9,  DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY), 'Ativa');

-- SECÇÃO 6: CONSULTAS SQL COMPLEXAS

-- Q1: Todos os livros emprestados atualmente
SELECT
em.Id_Emprestimo,
u.Nome AS Utilizador,
u.Tipo_Utilizador,
l.Titulo AS Livro,
l.ISBN,
em.Data_Emprestimo,
em.Data_Devolucao_Prevista,
em.Estado
FROM Emprestimo em
JOIN Utilizadores u ON em.Id_Utilizador = u.Id_Utilizador
JOIN Livro        l ON em.Id_Livro      = l.Id_Livro
WHERE em.Estado IN ('Emprestado', 'Atrasado')
ORDER BY em.Data_Devolucao_Prevista ASC;

-- Q2: Os 5 livros mais populares (mais emprestados)
SELECT
l.Id_Livro,
l.Titulo,
l.Categoria,
COUNT(em.Id_Emprestimo) AS Total_Emprestimos
FROM Livro l
JOIN Emprestimo em ON l.Id_Livro = em.Id_Livro
GROUP BY l.Id_Livro, l.Titulo, l.Categoria
ORDER BY Total_Emprestimos DESC
LIMIT 5;

-- Q3: Utilizadores com multas pendentes e valor total
SELECT
u.Id_Utilizador,
u.Nome,
u.Email,
u.Tipo_Utilizador,
COUNT(m.Id_Multa) AS Num_Multas_Pendentes,
SUM(m.Valor) AS Total_Divida_AOA
FROM Utilizadores u
JOIN Multas m ON u.Id_Utilizador = m.Id_Utilizador
WHERE m.Estado = 'Pendente'
GROUP BY u.Id_Utilizador, u.Nome, u.Email, u.Tipo_Utilizador
ORDER BY Total_Divida_AOA DESC;

-- Q4: Livros reservados por mais de um utilizador (ativas)
SELECT
l.Id_Livro,
l.Titulo,
l.Categoria,
COUNT(r.Id_Reserva) AS Num_Reservas_Ativas
FROM Livro l
JOIN Reservas r ON l.Id_Livro = r.Id_Livro
WHERE r.Estado = 'Ativa'
GROUP BY l.Id_Livro, l.Titulo, l.Categoria
HAVING COUNT(r.Id_Reserva) > 1
ORDER BY Num_Reservas_Ativas DESC;

-- Q5: Histórico completo de empréstimos do utilizador Id=1
SELECT
em.Id_Emprestimo,
l.Titulo,
l.ISBN,
em.Data_Emprestimo,
em.Data_Devolucao_Prevista,
em.Data_Devolucao_Real,
em.Estado,
m.Valor AS Multa_AOA
FROM Emprestimo em
JOIN Livro  l ON em.Id_Livro = l.Id_Livro
LEFT JOIN Multas m ON em.Id_Emprestimo = m.Id_Emprestimo
WHERE em.Id_Utilizador = 1
ORDER BY em.Data_Emprestimo DESC;

-- Q6: Taxa de atraso por TipoUtilizador
SELECT
u.Tipo_Utilizador,
COUNT(em.Id_Emprestimo) AS Total_Emprestimos,
SUM(CASE WHEN em.Estado = 'Atrasado' THEN 1 ELSE 0 END) AS Total_Atrasados,
ROUND(
SUM(CASE WHEN em.Estado = 'Atrasado' THEN 1 ELSE 0 END) * 100.0
/ COUNT(em.Id_Emprestimo), 2
) AS Taxa_Atraso_Pct
FROM Emprestimo em
JOIN Utilizadores u ON em.Id_Utilizador = u.Id_Utilizador
GROUP BY u.Tipo_Utilizador
ORDER BY Taxa_Atraso_Pct DESC;

-- Q7: Autores com livros em mais de 3 categorias diferentes
SELECT
a.Id_Autor,
a.Nome,
a.Nacionalidade,
COUNT(DISTINCT l.Categoria) AS Num_Categorias
FROM Autores a
JOIN Livro_Autor la ON a.Id_Autor = la.Id_Autor
JOIN Livro       l  ON la.Id_Livro = l.Id_Livro
GROUP BY a.Id_Autor, a.Nome, a.Nacionalidade
HAVING COUNT(DISTINCT l.Categoria) > 3
ORDER BY Num_Categorias DESC;

-- Q8: Livros que nunca foram emprestados
SELECT
l.Id_Livro,
l.Titulo,
l.ISBN,
l.Categoria,
l.Qtd_Total,
l.Qtd_Disponivel
FROM Livro l
WHERE l.Id_Livro NOT IN (
SELECT DISTINCT Id_Livro FROM Emprestimo
);

-- Q9: Utilizadores com mais de 5 empréstimos simultâneos (violações históricas)
SELECT
u.Id_Utilizador,
u.Nome,
u.Tipo_Utilizador,
COUNT(em.Id_Emprestimo) AS Emprestimos_Simultaneos
FROM Utilizadores u
JOIN Emprestimo em ON u.Id_Utilizador = em.Id_Utilizador
WHERE em.Estado IN ('Emprestado', 'Atrasado')
GROUP BY u.Id_Utilizador, u.Nome, u.Tipo_Utilizador
HAVING COUNT(em.Id_Emprestimo) > 5;

-- Q10: Relatório de empréstimos atrasados com dias de atraso
SELECT
em.Id_Emprestimo,
u.Nome AS Utilizador,
u.Tipo_Utilizador,
l.Titulo AS Livro,
em.Data_Emprestimo,
em.Data_Devolucao_Prevista,
COALESCE(em.Data_Devolucao_Real, CURRENT_DATE) AS Data_Real_Ou_Hoje,
DATEDIFF(
COALESCE(em.Data_Devolucao_Real, CURRENT_DATE),
em.Data_Devolucao_Prevista
) AS Dias_Atraso,
em.Estado
FROM Emprestimo em
JOIN Utilizadores u ON em.Id_Utilizador = u.Id_Utilizador
JOIN Livro l ON em.Id_Livro = l.Id_Livro
WHERE em.Estado = 'Atrasado'
OR (em.Estado = 'Emprestado' AND em.Data_Devolucao_Prevista < CURRENT_DATE)
ORDER BY Dias_Atraso DESC;

-- SECÇÃO 7: DCL — UTILIZADORES E PRIVILÉGIOS

-- ✅ CORRECÇÃO 3: Espaço removido entre 'bibliotecario'@ e 'localhost'
CREATE USER 'bibliotecario'@'localhost'    IDENTIFIED BY 'Biblio@2024!';
CREATE USER 'utilizador_comum'@'localhost' IDENTIFIED BY 'User@2024!';
CREATE USER 'admin_bd'@'localhost'         IDENTIFIED BY 'Admin@2024!';

-- Privilégios: bibliotecario — gestão completa de operações
GRANT SELECT, INSERT, UPDATE, DELETE ON BibliotecaUniversitaria.Livro        TO 'bibliotecario'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON BibliotecaUniversitaria.Emprestimo    TO 'bibliotecario'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON BibliotecaUniversitaria.Reservas      TO 'bibliotecario'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON BibliotecaUniversitaria.Multas        TO 'bibliotecario'@'localhost';
GRANT SELECT                         ON BibliotecaUniversitaria.Utilizadores  TO 'bibliotecario'@'localhost';
GRANT SELECT                         ON BibliotecaUniversitaria.Autores       TO 'bibliotecario'@'localhost';
GRANT SELECT                         ON BibliotecaUniversitaria.Editora       TO 'bibliotecario'@'localhost';
GRANT EXECUTE                        ON BibliotecaUniversitaria.*             TO 'bibliotecario'@'localhost';

-- Privilégios: utilizador_comum — consultar e reservar
GRANT SELECT ON BibliotecaUniversitaria.VW_LivrosDisponiveis           TO 'utilizador_comum'@'localhost';
GRANT SELECT ON BibliotecaUniversitaria.VW_EmprestimosAtivos           TO 'utilizador_comum'@'localhost';
GRANT SELECT ON BibliotecaUniversitaria.VW_ReservasAtivas              TO 'utilizador_comum'@'localhost';
GRANT SELECT ON BibliotecaUniversitaria.VW_UtilizadoresMultasPendentes TO 'utilizador_comum'@'localhost';
GRANT INSERT ON BibliotecaUniversitaria.Reservas                       TO 'utilizador_comum'@'localhost';

-- Privilégios: admin_bd — gestão de utilizadores e privilégios
GRANT CREATE USER, RELOAD ON *.* TO 'admin_bd'@'localhost' WITH GRANT OPTION;

FLUSH PRIVILEGES;

-- SECÇÃO 8: TCL — DEMONSTRAÇÃO DE TRANSAÇÕES COMPLEXAS

-- TCL 1: Tentativa de empréstimo de livro indisponível (deve ser revertida)
START TRANSACTION;
UPDATE Livro SET Qtd_Disponivel = 0 WHERE Id_Livro = 1;
ROLLBACK;
-- Resultado: Qtd_Disponivel reposta; nenhum empréstimo criado.

-- TCL 2: Devolução com atraso — gera multa via TRIGGER TRG_Emprestimo_AfterUpdate
START TRANSACTION;
UPDATE Emprestimo
SET Data_Devolucao_Real = CURRENT_DATE,
    Estado = 'Atrasado'
WHERE Id_Emprestimo = 36
AND Estado = 'Emprestado';
COMMIT;
-- Resultado: Estado atualizado, Qtd_Disponivel reposta, multa gerada se atrasado.

-- TCL 3: Tentativa de eliminar livro com empréstimos ativos (impedida por FK)
START TRANSACTION;
DELETE FROM Livro WHERE Id_Livro = 6;
ROLLBACK;
-- Resultado: Livro não eliminado; integridade referencial mantida.