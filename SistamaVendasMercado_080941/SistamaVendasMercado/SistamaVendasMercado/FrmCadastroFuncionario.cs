using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data.SqlClient;
using System.Drawing;
using System.Data;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SistamaVendasMercado
{
    public partial class FrmCadastroFuncionario : Form
    {
        public FrmCadastroFuncionario()
        {
            InitializeComponent();
        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void btnCadastrar_Click(object sender, EventArgs e)
        {

            try
            {
                using (SqlConnection con = Conexao.ObterConexao())
                {
                    string sql = @"INSERT INTO Funcionarios (Nome, Email, Telefone, Username, Senha, RoleID)
                           VALUES (@nome, @email, @tel, @user, @senha, @role)";

                    SqlCommand cmd = new SqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("@nome", txtNome.Text);
                    cmd.Parameters.AddWithValue("@email", txtEmail.Text);
                    cmd.Parameters.AddWithValue("@tel", txtTelefone.Text);
                    cmd.Parameters.AddWithValue("@user", txtUser.Text);
                    cmd.Parameters.AddWithValue("@senha", txtSenha.Text);
                    cmd.Parameters.AddWithValue("@role", cmbRole.SelectedValue);

                    con.Open();
                    cmd.ExecuteNonQuery();
                    MessageBox.Show("Funcionário cadastrado com sucesso!");
                }
            }
            catch (SqlException ex)
            {
                if (ex.Number == 2627) // Violação de UNIQUE
                    MessageBox.Show("Email ou Telefone já cadastrado!");
                else
                    MessageBox.Show("Erro: " + ex.Message);
            }
        }

        private void FrmCadastroFuncionario_Load(object sender, EventArgs e)
        {
            try
            {



                using (SqlConnection con = Conexao.ObterConexao())
                {
                    SqlDataAdapter da = new SqlDataAdapter("SELECT RoleID, NomeRole FROM Roles WHERE NomeRole != 'Admin'", con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    cmbRole.DataSource = dt;
                    cmbRole.DisplayMember = "NomeRole";
                    cmbRole.ValueMember = "RoleID";
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Erro ao carregar roles:" + ex.Message);
            }
        }

        private void btnSair_Click(object sender, EventArgs e)
        {
            MenuPrincipal menu = new MenuPrincipal();
            menu.ShowDialog();
        }

        private void panel1_Paint(object sender, PaintEventArgs e)
        {

        }

        private void txtSenha_TextChanged(object sender, EventArgs e)
        {

        }
    }
}