#include "fileUtils.h"

/* ouvre le fichier texte qui contiendra l'assembleur généré */
void initOutFile() {

  if ((fd =fopen("./out_inter.asm","w+")) == NULL) {
    fprintf(stderr,"Impossible de creer le fichier intermediaire de sortie assembleur\n");
    perror(" ");
    exit(1);
  }

}

/* 
 * A utiliser lorsque la compilation n'a pu finir
 * => Suppression du fichier assembleur qui n'a pas été généré 
 * complètement du fait de l'erreur de compilation
 */
void deleteOutFile() {

  fclose(fd);
  if (remove("./out_inter.asm") < 0) {
    fprintf(stderr,"Impossible de supprimer le fichier out_inter.asm incomplètement généré\n");
    perror(" ");
  }

}

/*
 * Remplace les labels par les adresses de lignes
 * qui conviennent
 * tabLabel tableau contenant l'adresse de chaque label (indice i = label $i)
 */
void replaceLabel(int * tabLabel) {

  FILE * fout;
  char fileLine[100]; // 1 ligne du fichier extrait
  char * ptrDollar;   // pointe le début du label trouvé
  int label;

  if ((fout =fopen("./out.asm","w+")) == NULL) {
    fprintf(stderr,"Impossible de creer le fichier de sortie assembleur\n");
    perror(" ");
    deleteOutFile();
    exit(1);
  }
  

  // traitement depuis début du fichier
  fseek(fd,0,SEEK_SET);

  while (fgets(fileLine,sizeof(fileLine),fd) != NULL) {

    ptrDollar = strrchr(fileLine,'$');
  
    if (ptrDollar != NULL) { // étiquette trouvée
      sscanf(ptrDollar,"$%d",&label);
      sprintf(ptrDollar,"%d%s",tabLabel[label],"\n\0");
    }

    fprintf(fout,"%s",fileLine);

  }

  deleteOutFile(); // suppression fichier intermédiaire
  fclose(fout);
}
