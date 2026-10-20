package pe.edu.oceanlink.servlet;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import pe.edu.oceanlink.dao.ClienteDAO;
import pe.edu.oceanlink.bean.Cliente;

import java.io.IOException;
import java.util.ArrayList;

@WebServlet(name = "ClienteServlet", value = "/ClienteServlet")
public class ClienteServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");
        ClienteDAO clienteDao = new ClienteDAO();
        RequestDispatcher view;

        switch (action) {
            case "lista":
                ArrayList<Cliente> listaTrabajos = clienteDao.obtenerListaTrabajos();
                request.setAttribute("lista", listaTrabajos);
                view = request.getRequestDispatcher("/views/clientes.jsp");
                view.forward(request, response);
                break;
            case "formCrear":
                view = request.getRequestDispatcher("/views/cliente-form.jsp");
                view.forward(request, response);
                break;
            case "editar":
                String jobId = request.getParameter("id");
                Cliente cliente = clienteDao.obtenerTrabajo(jobId);
                if (cliente == null) {
                    response.sendRedirect(request.getContextPath() + "/ClienteServlet");
                } else {
                    request.setAttribute("cliente", cliente);
                    view = request.getRequestDispatcher("/views/cliente-form.jsp");
                    view.forward(request, response);
                }
                break;
            case "cambiarEstado":
                String idDelete = request.getParameter("id");
                String estado = request.getParameter("estado"); clienteDao.cambiarEstado(idDelete, estado);
                response.sendRedirect(request.getContextPath() + "/ClienteServlet?action=lista");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action") == null ? "lista" : request.getParameter("action");
        ClienteDAO clienteDao = new ClienteDAO();

        switch (action) {
            case "crear":
                String idCliente = request.getParameter("idCliente");
                String razonSocial = request.getParameter("razonSocial");
                String ruc = request.getParameter("ruc");
                String telefono = request.getParameter("telefono");
                String correo = request.getParameter("correo");
                String direccion = request.getParameter("direccion");
                String contacto = request.getParameter("contacto");
                String estado = request.getParameter("estado");

                Cliente clienteGuardar = new Cliente();
                clienteGuardar.setRazonSocial(razonSocial);
                clienteGuardar.setRuc(ruc);
                clienteGuardar.setTelefono(telefono);
                clienteGuardar.setCorreo(correo);
                clienteGuardar.setDireccion(direccion);
                clienteGuardar.setContacto(contacto);
                clienteGuardar.setEstado(estado);

                if (idCliente == null || idCliente.isEmpty()) {
                    clienteDao.crearTrabajo(clienteGuardar);
                } else {
                    clienteGuardar.setIdCliente(Integer.parseInt(idCliente));
                    clienteDao.actualizarTrabajo(clienteGuardar);
                }

                String op = (idCliente == null || idCliente.isEmpty()) ? "crear" : "editar";
                response.sendRedirect(request.getContextPath() + "/views/operacion-exito.jsp?mod=cliente&op=" + op);
                break;
        }
    }
}
