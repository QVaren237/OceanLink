package pe.edu.oceanlink.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import pe.edu.oceanlink.dao.IncidenciaDAO;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name="EstadoRedServlet",urlPatterns="/EstadoRedServlet")
public class EstadoRedServlet extends HttpServlet {
    private final IncidenciaDAO dao=new IncidenciaDAO();
    @Override protected void doGet(HttpServletRequest req,HttpServletResponse resp)throws ServletException,IOException{
        req.setCharacterEncoding("UTF-8");
        try{
            req.setAttribute("lista",dao.listarEstadoRed(req.getParameter("buscar"),req.getParameter("estado")));
            req.getRequestDispatcher("/views/network-estado-red.jsp").forward(req,resp);
        }catch(SQLException e){throw new ServletException("Error consultando estado de red",e);}
    }
}
