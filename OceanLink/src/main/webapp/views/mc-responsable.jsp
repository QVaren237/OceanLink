<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*,pe.edu.oceanlink.bean.Usuario" %>
<%! private String h(Object v){return v==null?"":v.toString().replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");} %>
<% if(!(session.getAttribute("usuarioSesion") instanceof Usuario)){
ArrayList<String[]> responsables=(ArrayList<String[]>)request.getAttribute("responsablesMC");if(responsables==null)responsables=new ArrayList<>();
String seleccionado=request.getParameter("idResponsable");Object borrador=request.getAttribute("borradorMC");if(seleccionado==null&&borrador instanceof Map)seleccionado=String.valueOf(((Map<?,?>)borrador).get("idResponsable")); %>
<div class="field mc-responsable"><label for="mcResponsable">Coordinador responsable (*)</label><select class="input" id="mcResponsable" name="idResponsable" required><option value="">Selecciona al responsable</option><% for(String[] u:responsables){ %><option value="<%=h(u[0])%>" <%=u[0].equals(seleccionado)?"selected":""%>><%=h(u[1])%></option><% } %></select></div>
<% } %>
