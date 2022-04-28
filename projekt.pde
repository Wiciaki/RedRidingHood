import gab.opencv.*;
import processing.video.*;
import java.awt.*;
import jp.nyatla.nyar4psg.*;
import processing.sound.*;

// zmienne bibliotek i zwiazane z przetwarzaniem obrazu
Capture video;
OpenCV opencv;
MultiMarker nya;

// zmienne z odnosnikami do zasobow aplikacji
PImage m47, m17, m56;
PImage quizTlo, sukces, porazka;
PImage tlo, wilk, grandma, mom, koniec;
SoundFile howl;

// stan aplikacji
int stateId, markerCount;
boolean isButtonClicked, isCorrectAnswer;
int lastAnswerTime = Integer.MIN_VALUE;

// przygotuj aplikacje do dzialania
void setup() {
  size(800, 640, P3D);

  video = new Capture(this, width, height, "pipeline:autovideosrc");
  opencv = new OpenCV(this, width, height);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);

  nya = new MultiMarker(this, width, height, "data/camera_para.dat", NyAR4PsgConfig.CONFIG_PSG);

  nya.addARMarker("data/4x4_47.patt", 80);
  nya.addARMarker("data/4x4_17.patt", 80);
  markerCount = nya.addARMarker("data/4x4_56.patt", 80);

  rectMode(CENTER);
  textAlign(CENTER);
  textFont(createFont("fonts/arialb.ttf", 20));

  m47 = loadImage("data/4x4_384_47.gif");
  m17 = loadImage("data/4x4_384_17.gif");
  m56 = loadImage("data/4x4_384_56.gif");

  quizTlo = loadImage("images/quizTlo.png");
  sukces = loadImage("images/sukces.png");
  porazka = loadImage("images/porazka.png");

  tlo = loadImage("images/tlo1.jpg");
  grandma = loadImage("images/grandma.jpg");
  mom = loadImage("images/mom.jpg");
  wilk = loadImage("images/wilk.png");
  koniec = loadImage("images/koniec.jpg");

  howl = new SoundFile(this, "sounds/howl.wav");

  surface.setTitle("Aktywne Czytanie - Przygody Czerwonego Kapturka");
  video.start();
}

// funkcja wbudowana processing
void mouseClicked() {
  if (mouseX > 320 && mouseX < 480 && mouseY > 475 && mouseY < 565) {
    isButtonClicked = true;
  }
}

// funkcja detekcji kliknięcia przycisku
boolean waitForClick() {
  if (isButtonClicked) {
    isButtonClicked = false;
    stateId++;
    return true;
  }

  return false;
}

// glówna funkcja rysująca każdą klatkę
void draw() {
  if (!video.available()) {
    return;
  }

  video.read();
  nya.detect(video);

  String txt;

  switch (stateId) {
  case 0:
    txt = "Witaj w bajkowym świecie\nCzerwonego Kapturka!\nCzy chcesz zmierzyć się ze strasznymi\nprzeszkodami i pomóc Kapturkowi\ndostarczyć koszyczek dla Babci?";

    image(tlo, 0, 0);

    fill(#905A5A);
    textSize(20);
    text(txt, 590, 40);

    fill(#8B0000);
    textSize(25);
    text("Jeśli jesteś na\ntyle odważny:", 220, height/2 + 120);

    fill(#ED6E6E);
    rect(width/2, height/2 + 200, 150, 80, 30);

    fill(#FFFFFF);
    textSize(25);
    text("Kliknij!", width/2, height/2 + 200);

    waitForClick();
    break;
  case 1:
    txt = "Z Babcią jest coś nie tak!\nAle co tak właściwie nie pasuje?\nPomóż Kapturkowi\nrozwikłać zagadkę!";

    image(grandma, 0, 0);

    textSize(20);
    fill(#457AEA);
    text(txt, 200, 60);

    fill(#FFFFFF);
    textSize(25);
    text("...jeżeli jesteś ciekawy", width/2, height - 40);

    fill(#ED6E6E);
    rect(width/2, height/2 + 200, 150, 80, 30);

    fill(#FFFFFF);
    textSize(25);
    text("Kliknij!", width/2, height/2 + 200);

    if (waitForClick()) {
      howl.play();
    }
    break;
  case 2:
    txt = "Czemu masz takie wielkie oczy, babciu?\nPokaż ten znacznik, aby przejść dalej:";

    image(video, 0, 0);

    opencv.loadImage(video);
    Rectangle[] faces = opencv.detect();

    for (int i = 0; i < faces.length; i++) {
      image(wilk, faces[i].x, faces[i].y-50, faces[i].width, faces[i].height);
    }

    textSize(20);
    fill(#0047AB);
    text(txt, 460, 30);

    image(m47, 680, 20, width/10, width/10);

    for (int i = 0; i < markerCount; i++) {
      if (nya.isExist(i)) {
        if (i == 0) {
          stateId++;
        }
      }
    }
    break;
  case 3:
    txt = "Babcia Czerwonego Kaptuka jest chora\nMama wysłała Kapturka do Babci z koszyczkiem\nPomóż Kapturkowi rozwiązać quiz, żeby mogła\nbezpiecznie dotrzeć do Babci!";

    image(mom, 0, 0);

    textSize(20);
    fill(#FC6736);
    text(txt, 240, 70);

    fill(#0047AB);
    textSize(25);
    text("Pomóż Kapturkowi!", width/2, height - 50);

    fill(#ED6E6E);
    rect(width/2, height/2 + 200, 150, 80, 30);

    fill(#FFFFFF);
    textSize(25);
    text("Kliknij!", width/2, height/2 + 200);
    waitForClick();
    break;
  case 4:
    quiz(0);
    break;
  case 5:
    quiz(1);
    break;
  case 6:
    quiz(2);
    break;
  default:
    image(koniec, 0, 0);
    break;
  }
}

class QuizEntry
{
  final String question, firstAnswer, secondAnswer;
  final int correctAnswer;

  QuizEntry(String question, String firstAnswer, String secondAnswer, int correctAnswer) {
    this.question = question;
    this.firstAnswer = firstAnswer;
    this.secondAnswer = secondAnswer;
    this.correctAnswer = correctAnswer;
  }
}

final QuizEntry[] quizEntries = new QuizEntry[] {
  new QuizEntry("Z jakiego materiału uszyty\nbył czerwony kapturek", "z lnu", "z aksamitu", 2),
  new QuizEntry("Co Czerwony Kapturek\nniosła w koszyczku", "placek i wino", "rogaliki i mleko", 1),
  new QuizEntry("Pod jakimi drzewami\nstał domek babci", "pod trzema\nwielkimi dębami", "pod dwoma\nleszczynami", 1)
};

// funkcja zadająca pytania i wyświetlająca wykrytą odpowiedź
void quiz(int id) {
  final QuizEntry entry = quizEntries[id];
  final int time = millis();

  if (time - lastAnswerTime < 3000) {
    image(isCorrectAnswer ? sukces : porazka, 0, 0);
    return;
  }

  image(quizTlo, 0, 0);

  final int s = width / 10;
  image(m17, 60, 40, s, s);
  image(m56, width - 140, 40, s, s);

  textSize(20);
  fill(#FC6736);
  text(entry.firstAnswer, 100, 160);
  text(entry.secondAnswer, width - 100, 160);

  textSize(25);
  fill(#000000);
  text(entry.question, width / 2, 80);

  int w = width / 4;
  int h = height / 4;
  image(video, width - w - 40, height - h - 40, w, h);

  for (int i = 0; i < markerCount; i++) {
    if (nya.isExist(i)) {
      if (i == 1 || i == 2) {
        lastAnswerTime = time;
        isCorrectAnswer = entry.correctAnswer == i;

        if (isCorrectAnswer) {
          stateId++;
        }
      }
    }
  }
}
