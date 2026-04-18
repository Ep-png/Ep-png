const express = require('express');
const jwt = require('jsonwebtoken');
const app = express();
app.use(express.json());

const SEGREDO = 'sua_chave_secreta_aqui';

app.post('/login', (req, res) => {
  const usuario = {
    id: 1,
    nome: 'Maria',
    email: 'maria@email.com'
  };

  jwt.sign(
    usuario,
    SEGREDO,
    { expiresIn: '1h' },
    (erro, token) => {
      if (erro) {
        res.status(500).json({ erro: 'Falha ao gerar token' });
      } else {
        res.json({ token: token });
      }
    }
  );
});

function verificarToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ erro: 'Acesso negado. Token não fornecido.' });
  }

  try {
    const decoded = jwt.verify(token, SEGREDO);
    req.usuario = decoded;
    next();
  } catch (erro) {
    res.status(400).json({ erro: 'Token inválido ou expirado' });
  }
}

app.get('/dados-protegidos', verificarToken, (req, res) => {
  res.json({
    mensagem: 'Você acessou uma rota protegida!',
    usuario: req.usuario
  });
});

app.listen(3000, () => {
  console.log('Servidor rodando na porta 3000');
});

