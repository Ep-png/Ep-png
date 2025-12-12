const express = require("express");
const jsonfile = require("jsonfile");
const app = express();

app.use(express.json());

const pacientesDB = "./dados/pacientes.json";
const medicosDB = "./dados/medicos.json";
const especialidadesDB = "./dados/especialidades.json";
const consultasDB = "./dados/consultas.json";

async function ler(caminho) {
    try {
        return await jsonfile.readFile(caminho);
    } catch {
        return { pacientes: [], medicos: [], especialidades: [], consultas: [] };
    }
}

async function escrever(caminho, dados) {
    await jsonfile.writeFile(caminho, dados, { spaces: 2 });
}

app.post("/especialidades", async (req, res) => {
    // POST http://localhost:3000/especialidades
    // {
    //   "nome": "Cardiologia",
    //   "descricao": "Especialidade do coração"
    // }

    const db = await ler(especialidadesDB);
    const { nome, descricao } = req.body;

    const nova = {
        idEspecialidade: Date.now(),
        nome,
        descricao
    };

    db.especialidades.push(nova);
    await escrever(especialidadesDB, db);

    res.status(201).json({ mensagem: "Especialidade cadastrada!", especialidade: nova });
});

app.get("/especialidades", async (req, res) => {
    // GET http://localhost:3000/especialidades
    const db = await ler(especialidadesDB);
    res.json(db.especialidades);
});

app.post("/medicos", async (req, res) => {
    // POST http://localhost:3000/medicos
    // {
    //   "nome": "Dr. João Silva",
    //   "crm": "123456",
    //   "idEspecialidade": 1734029140000
    // }

    const medicos = await ler(medicosDB);
    const especialidades = await ler(especialidadesDB);

    const { nome, crm, idEspecialidade } = req.body;

    const existe = especialidades.especialidades.find(e => e.idEspecialidade === idEspecialidade);
    if (!existe)
        return res.status(400).json({ erro: "Especialidade não encontrada!" });

    const novo = {
        idMedico: Date.now(),
        nome,
        crm,
        idEspecialidade
    };

    medicos.medicos.push(novo);
    await escrever(medicosDB, medicos);

    res.status(201).json({ mensagem: "Médico cadastrado!", medico: novo });
});

app.get("/medicos", async (req, res) => {
    // GET http://localhost:3000/medicos
    const db = await ler(medicosDB);
    res.json(db.medicos);
});

app.post("/pacientes", async (req, res) => {
    // POST http://localhost:3000/pacientes
    // {
    //   "nome": "Maria Oliveira",
    //   "email": "maria@gmail.com",
    //   "telefone": "99999-9999",
    //   "dataNascimento": "2000-05-22"
    // }

    const db = await ler(pacientesDB);
    const { nome, email, telefone, dataNascimento } = req.body;

    const novo = {
        idPaciente: Date.now(),
        nome,
        email,
        telefone,
        dataNascimento
    };

    db.pacientes.push(novo);
    await escrever(pacientesDB, db);

    res.status(201).json({ mensagem: "Paciente cadastrado!", paciente: novo });
});

app.get("/pacientes", async (req, res) => {
    // GET http://localhost:3000/pacientes
    const db = await ler(pacientesDB);
    res.json(db.pacientes);
});

app.post("/consultas", async (req, res) => {
    // POST http://localhost:3000/consultas
    // {
    //   "idPaciente": 1734029000000,
    //   "idMedico": 1734029140000,
    //   "dataHora": "2025-01-10 14:00",
    //   "observacoes": "Consulta de rotina"
    // }

    const consultas = await ler(consultasDB);
    const pacientes = await ler(pacientesDB);
    const medicos = await ler(medicosDB);

    const { idPaciente, idMedico, dataHora, observacoes } = req.body;

    const paciente = pacientes.pacientes.find(p => p.idPaciente === idPaciente);
    if (!paciente)
        return res.status(400).json({ erro: "Paciente não existe!" });

    const medico = medicos.medicos.find(m => m.idMedico === idMedico);
    if (!medico)
        return res.status(400).json({ erro: "Médico não existe!" });

    const nova = {
        idConsulta: Date.now(),
        idPaciente,
        idMedico,
        dataHora,
        status: "AGENDADA",
        observacoes
    };

    consultas.consultas.push(nova);
    await escrever(consultasDB, consultas);

    res.status(201).json({ mensagem: "Consulta marcada!", consulta: nova });
});

app.get("/consultas", async (req, res) => {
    // GET http://localhost:3000/consultas
    const db = await ler(consultasDB);
    res.json(db.consultas);
});

app.patch("/consultas/:id/status", async (req, res) => {
    // PATCH http://localhost:3000/consultas/ID/status
    // {
    //   "status": "CONCLUIDA"
    // }

    const consultas = await ler(consultasDB);
    const consulta = consultas.consultas.find(c => c.idConsulta == req.params.id);

    if (!consulta)
        return res.status(404).json({ erro: "Consulta não encontrada!" });

    const { status } = req.body;
    consulta.status = status;

    await escrever(consultasDB, consultas);
    res.json({ mensagem: "Status atualizado!", consulta });
});

app.get("/", (req, res) => res.send("API – Sistema de Consultas Médicas"));

app.listen(3000, () => console.log("Rodando em http://localhost:3000"));

Se quiser, tiro até os comentários de Postman e deixo completamente limpo — só pedir!