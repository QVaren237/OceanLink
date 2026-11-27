(function(){
  if(window.__ocValida) return; window.__ocValida=true;

  function anclaje(f){
    var p=f.parentElement;
    if(p && p.classList && (p.classList.contains('pass-wrap') || p.classList.contains('password-field'))) return p;
    return f;
  }
  function existente(f){
    var a=anclaje(f).nextElementSibling;
    if(a && a.classList && (a.classList.contains('err') || a.classList.contains('err-msg'))) return a;
    return null;
  }
  function mensaje(f){
    var v=f.validity;
    if(v.valueMissing) return 'Este campo es obligatorio.';
    if(f.type==='email' && v.typeMismatch) return 'Ingrese un correo válido. Ejemplo: usuario@dominio.com';
    if(v.typeMismatch) return 'El formato ingresado no es válido.';
    if(v.patternMismatch) return (f.title && f.title.trim()) ? f.title : 'El formato ingresado no es válido.';
    if(v.rangeUnderflow) return 'El valor es menor al permitido.';
    if(v.rangeOverflow) return 'El valor es mayor al permitido.';
    if(v.stepMismatch) return 'El valor ingresado no es válido.';
    if(v.tooShort) return 'El texto es demasiado corto.';
    if(v.tooLong) return 'El texto es demasiado largo.';
    if(v.badInput) return 'Ingrese un valor válido.';
    return 'Revisa este campo.';
  }
  function limpiar(f){
    f.style.borderColor='';
    var m=existente(f);
    if(m){ if(m.classList.contains('err-auto')) m.parentNode.removeChild(m); else m.style.display='none'; }
  }
  function mostrar(f,txt){
    f.style.borderColor='#c0334a';
    var m=existente(f);
    if(!m){
      m=document.createElement('small'); m.className='err err-auto'; m.style.display='block';
      var a=anclaje(f); a.parentNode.insertBefore(m, a.nextSibling);
    }
    m.textContent=txt; m.style.display='block';
    if(!f.__ocBound){
      f.__ocBound=true;
      var limpia=function(){ if(f.checkValidity()) limpiar(f); };
      f.addEventListener('input',limpia); f.addEventListener('change',limpia);
    }
  }
  function validable(f){
    return !(f.disabled || f.type==='hidden' || f.type==='submit' || f.type==='button' || f.type==='reset');
  }
  function apagarNativo(){
    var fs=document.querySelectorAll('form');
    for(var i=0;i<fs.length;i++) fs[i].setAttribute('novalidate','');
  }
  if(document.readyState!=='loading') apagarNativo();
  else document.addEventListener('DOMContentLoaded', apagarNativo);

  document.addEventListener('submit', function(ev){
    var form=ev.target;
    if(!(form instanceof HTMLFormElement)) return;
    form.setAttribute('novalidate','');
    var c=form.querySelectorAll('input,select,textarea'), ok=true, primero=null;
    for(var i=0;i<c.length;i++){
      var f=c[i];
      if(!validable(f)) continue;
      limpiar(f);
      if(!f.checkValidity()){ mostrar(f, mensaje(f)); ok=false; if(!primero) primero=f; }
    }
    if(!ok){ ev.preventDefault(); ev.stopPropagation(); if(primero && primero.focus) primero.focus(); }
  }, true);
})();
