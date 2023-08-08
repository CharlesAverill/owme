// clang find_fonts.c -lX11 -o find_fonts
// https://openclassrooms.com/forum/sujet/ocaml-changer-la-taille-du-texte-avec-graphics
// Alternatively, xfontsel

#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xos.h>
#include <stdio.h>
 
int main(void){
 
  int nfonts;
 
  Display *dpy = XOpenDisplay(0);
  if(!dpy) return -1;
 
  char **cfonts = XListFonts(dpy, "*--0-0-*iso8859-*", -1, &nfonts);
  
  int i;
  for(i=0;i<nfonts;i++){
      printf("%s\n", cfonts[i]);
  }
 
  if(cfonts) XFreeFontNames(cfonts);
  XCloseDisplay(dpy);
  return 0;
 
}
