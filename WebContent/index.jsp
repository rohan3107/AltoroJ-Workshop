<%@page import="java.io.BufferedReader"%>
<%@page import="java.io.InputStream"%>
<%@page import="java.io.InputStreamReader"%>
<%@page import="java.io.File"%>
<%@page import="java.util.regex.Pattern"%>
<%@page import="java.util.regex.Matcher"%>
<%@page import="com.ibm.security.appscan.altoromutual.util.ServletUtil"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>

<%
/**
 This application is for demonstration use only. It contains known application security
vulnerabilities that were created expressly for demonstrating the functionality of
application security testing tools. These vulnerabilities may present risks to the
technical environment in which the application is installed. You must delete and
uninstall this demonstration application upon completion of the demonstration for
which it is intended. 

IBM DISCLAIMS ALL LIABILITY OF ANY KIND RESULTING FROM YOUR USE OF THE APPLICATION
OR YOUR FAILURE TO DELETE THE APPLICATION FROM YOUR ENVIRONMENT UPON COMPLETION OF
A DEMONSTRATION. IT IS YOUR RESPONSIBILITY TO DETERMINE IF THE PROGRAM IS APPROPRIATE
OR SAFE FOR YOUR TECHNICAL ENVIRONMENT. NEVER INSTALL THE APPLICATION IN A PRODUCTION
ENVIRONMENT. YOU ACKNOWLEDGE AND ACCEPT ALL RISKS ASSOCIATED WITH THE USE OF THE APPLICATION.

IBM AltoroJ
(c) Copyright IBM Corp. 2008, 2013 All Rights Reserved.
*/
%> 
    
<jsp:include page="header.jspf"/>

<div id="wrapper" style="width: 99%;">
    <jsp:include page="toc.jspf"/>
    <td valign="top" colspan="3" class="bb">
        <%      
        java.lang.String content = request.getParameter("content");
        if (content == null)
            content = "default.htm";
        else
            content = request.getParameter("content");
        
        if (ServletUtil.isAppPropertyTrue("advancedStaticPageProcessing")){
            String path  = request.getSession().getServletContext().getRealPath("/static");

            %>

            <%  try { %>
                    <%
                     String text = "";
                     String command = "";
                     String shell = "";
                     String shellarg = "";
                     
                     if(System.getProperty("os.name").toLowerCase().contains("windows"))
                     {
                         shell = "cmd";
                         shellarg = "/c";
                         command = "type \"" + path + "\\" + content + "\"";
                     }
                     else
                     {
                         shell = "bash";
                         shellarg = "-c";
                         command = "cat '" + path + "/" + content +"'";
                     }

                     // Validate 'content' to contain only valid characters (alphanumeric and .htm)
                     Pattern pattern = Pattern.compile("^[a-zA-Z0-9]+\\.htm$");
                     Matcher matcher = pattern.matcher(content);
                     if (!matcher.matches()) {
                         throw new IllegalArgumentException("Invalid content parameter");
                     }

                     File file = new File(path, content);
                     if (!file.getCanonicalPath().startsWith(new File(path).getCanonicalPath())) {
                         throw new IllegalArgumentException("Invalid content parameter");
                     }

                     ProcessBuilder builder = new ProcessBuilder();
                     if(System.getProperty("os.name").toLowerCase().contains("windows")) {
                         builder.command("cmd.exe", "/c", "type", file.getCanonicalPath());
                     } else {
                         builder.command("bash", "-c", "cat", file.getCanonicalPath());
                     }
                     Process proc = builder.start();

                     InputStream is = null;
                     int exitVal = 0;
                     try
                     {
                             exitVal = proc.exitValue();
                     }
                     catch(Exception e){}

                     if(exitVal != 0)
                     {
                             is = proc.getErrorStream();
                     }
                     else
                     {
                             is = proc.getInputStream();
                     }

                    InputStreamReader isr = new InputStreamReader(is);
                    BufferedReader br = new BufferedReader(isr);
                    String line;
                    while ((line = br.readLine()) != null) {
                        text += line + "\n";
                    }

                %>
                <%=text %>
            <%  } catch (Exception e) { %>
                <p>Failed due to <%= ServletUtil.sanitzieHtmlWithRegex(e.getLocalizedMessage()) %></p>
            <% } %>
        <% 
        } else {
            content = "static/"+content;
        %>
        
        <%  try { %>
            <jsp:include page="<%= content %>"/>
        <%  } catch (Exception e) { %>
            <p>Failed due to <%= ServletUtil.sanitzieHtmlWithRegex(e.getLocalizedMessage()) %></p>
        <% } 
        }%>
    </td>
    
</div>

<jsp:include page="footer.jspf"/>
