const SUPABASE_URL = "https://aakvyrujjynvdwnsvnbt.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFha3Z5cnVqanludmR3bnN2bmJ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgxNjIzNTYsImV4cCI6MjA5MzczODM1Nn0.4z_qfMFgIjrcE_Ha4oC3Z-xWyg8CnhPm4dHKkEvfo70";

if (window.supabase) {
  window.supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
}

function setAuthMessage(message) {
  const box = document.getElementById("authError");
  if (box) box.textContent = message || "";
}

function openSystemAfterLogin(session) {
  document.body.classList.remove("auth-locked");
  document.body.classList.add("auth-ready");
  const sessionUser = document.getElementById("sessionUser");
  if (sessionUser) sessionUser.textContent = session?.user?.email || "";
  if (typeof window.renderAll === "function") window.renderAll();
}

window.loginSupabase = async function loginSupabase(event) {
  if (event) event.preventDefault();
  const button = document.getElementById("loginBtn");
  const email = document.getElementById("loginEmail")?.value.trim();
  const password = document.getElementById("loginPassword")?.value;

  setAuthMessage("");
  if (!email || !password) {
    setAuthMessage("Debe escribir correo y contraseña.");
    return false;
  }

  try {
    if (button) {
      button.disabled = true;
      button.textContent = "Validando...";
    }
    if (!window.supabaseClient) {
      throw new Error("No se pudo cargar la librería de Supabase. Revise la conexión a internet.");
    }
    const { data, error } = await window.supabaseClient.auth.signInWithPassword({ email, password });
    if (error) throw error;
    openSystemAfterLogin(data.session);
  } catch (error) {
    setAuthMessage(error.message || "No fue posible iniciar sesión.");
  } finally {
    if (button) {
      button.disabled = false;
      button.textContent = "Iniciar sesión";
    }
  }
  return false;
};

window.logoutSupabase = async function logoutSupabase() {
  if (window.supabaseClient) await window.supabaseClient.auth.signOut();
  document.body.classList.add("auth-locked");
  document.body.classList.remove("auth-ready");
};

document.addEventListener("DOMContentLoaded", async () => {
  const password = document.getElementById("loginPassword");
  if (password) {
    password.addEventListener("keydown", event => {
      if (event.key === "Enter") window.loginSupabase(event);
    });
  }
  if (!window.supabaseClient) {
    setAuthMessage("No se pudo cargar la librería de Supabase. Revise la conexión a internet.");
    return;
  }
  const { data } = await window.supabaseClient.auth.getSession();
  if (data.session) openSystemAfterLogin(data.session);
});
