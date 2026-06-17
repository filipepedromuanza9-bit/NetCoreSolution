using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SistamaVendasMercado
{
    public partial class FrmCadastroCliente : Form
    {
        int clienteID = 0;

        public FrmCadastroCliente()
        {
            InitializeComponent();
        }
        private void dataGridView1_CellContentClick(object sender, DataGridViewCellEventArgs e)
        {

        }

        private void btnSalvar_Click(object sender, EventArgs e)
        {



            if (string.IsNullOrWhiteSpace(txtNome.Text) || string.IsNullOrWhiteSpace(txtTelefone.Text))
            {
                MessageBox.Show("Nome e Telefone são obrigatórios!");
                return;
            }

            try
            {
                using (SqlConnection con = Conexao.ObterConexao())
                {
                    string sql = clienteID == 0
                        ? "INSERT INTO Clientes (Nome, Telefone, Email, Endereco) VALUES (@nome, @tel, @email, @end)"
                        : "UPDATE Clientes SET Nome=@nome, Telefone=@tel, Email=@email, Endereco=@end WHERE ClienteID=@id";

                    SqlCommand cmd = new SqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("@nome", txtNome.Text.Trim());
                    cmd.Parameters.AddWithValue("@tel", txtTelefone.Text.Trim());
                    cmd.Parameters.AddWithValue("@email", string.IsNullOrWhiteSpace(txtEmail.Text) ? DBNull.Value : (object)txtEmail.Text.Trim());
                    cmd.Parameters.AddWithValue("@end", string.IsNullOrWhiteSpace(txtEndereco.Text) ? DBNull.Value : (object)txtEndereco.Text.Trim());
                    if (clienteID > 0) cmd.Parameters.AddWithValue("@id", clienteID);

                    con.Open();
                    cmd.ExecuteNonQuery();
                    MessageBox.Show(clienteID == 0 ? "Cliente cadastrado!" : "Cliente atualizado!");
                    Limpar();
                    CarregarClientes();
                }
            }
            catch (SqlException ex)
            {
                if (ex.Number == 2627) MessageBox.Show("Telefone ou Email já cadastrado!");
                else MessageBox.Show("Erro: " + ex.Message);
            }
        }

        private void dgvClientes_CellClick(object sender, DataGridViewCellEventArgs e)
        {
            if (e.RowIndex >= 0)
            {
                var r = dgvClientes.Rows[e.RowIndex];
                clienteID = Convert.ToInt32(r.Cells["ClienteID"].Value);
                txtNome.Text = r.Cells["Nome"].Value.ToString();
                txtTelefone.Text = r.Cells["Telefone"].Value.ToString();
                txtEmail.Text = r.Cells["Email"].Value.ToString();
                txtEndereco.Text = r.Cells["Endereco"].Value.ToString();
            }
        }

        void Limpar()
        {
            clienteID = 0;
            txtNome.Clear(); txtTelefone.Clear(); txtEmail.Clear(); txtEndereco.Clear();
        }
















        private void FrmCadastroCliente_Load(object sender, EventArgs e)
        {
            CarregarClientes();
        }

        void CarregarClientes()
        {
            using (SqlConnection con = Conexao.ObterConexao())
            {
                string sql = "SELECT ClienteID, Nome, Telefone, Email, Endereco FROM Clientes";
                SqlDataAdapter da = new SqlDataAdapter(sql, con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                dgvClientes.DataSource = dt;
                dgvClientes.Columns["ClienteID"].Visible = false;
            }
        }

        private void btnLimpar_Click(object sender, EventArgs e)
        {

        }

        private void btnSair_Click(object sender, EventArgs e)
        {
            MenuPrincipal menu = new MenuPrincipal();
            menu.ShowDialog();
        }
    }
    }

