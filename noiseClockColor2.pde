float centerH = 0;
float widthH = 0.7;


float minB = 0.3;
float maxB = 1.0;
float alpha = 0.04;
float transStart = 0.35;
float transWidth = 0.01;
float transStart2 = 0.45;
float transWidth2 = 0.01;

float radTransStart = 0.18;
float radTransWidth = 0.15;

float ah = 0.02;
float ab = 0.055;
float af = 0.014;
float ag = 1;

float th = 0.060;
float tb = 0.010;
float tf = 0.005;
float tc = 0.003;
float tA = 0.4;

int numSpokes = 12;
float ang;
int w = 1;
float slope;

float[] px;
float[] py;
float[] pf;
int[] pa;

color[] P;

float cr = 4;
float hourWidth = 0.013;
float hourLength = 0.2;
float minuteWidth = 0.013;
float minuteLength = 0.25;
float secondWidth = 0.01;
float secondLength = 0.57;
float backEnd = 0.04;

int startTime;
int startSeconds;

float xRes;
float yRes;
void setup() {
  size( 800, 480 );
  xRes = float(width);
  yRes = float(height);
  centerH = random(0, 1);
  noStroke();
  background(0);
  ang = 2*PI/float(numSpokes);
  slope = tan(0.5*ang);

  startTime = millis();
  startSeconds = second();
  println(startSeconds);

  P = new color[(width/2)*(height/2)];
  for ( int x = 0; x < width/2; x++ ) {
    for ( int y = 0; y < height/2; y++ ) {
      P[x+y*width/2] = color(0, 0, 0);
    }
  }

  px = new float[(width/2)*(height/2)];
  py = new float[(width/2)*(height/2)];
  pf = new float[(width/2)*(height/2)];
  pa = new int[(width/2)*(height/2)];
  for ( int x = 0; x < width/2; x++ ) {
    for ( int y = 0; y < height/2; y++ ) {
      float x2 = float(x) + 0.5;
      float y2 = float(y) + 0.5;
      PVector v = new PVector( x2, y2 );
      float a = (v.heading() + PI)%ang;
      if ( a > 0.5*ang ) { 
        a = ang - a;
      }
      float r = v.mag();
      px[x+y*width/2] = r*cos(a);
      py[x+y*width/2] = r*sin(a);
      if ( r < radTransStart*yRes ) {
        pf[x+y*width/2] = 0;
      } else if  (r >= (radTransStart)*yRes && r < (radTransStart+radTransWidth)*yRes ) {
        pf[x+y*width/2] = (r-(radTransStart*yRes))/(radTransWidth*yRes);
      } else {
        pf[x+y*width/2] = 1;
      }
      pa[x+y*width/2] = 0;
    }
  }
}

void draw() {
  float t = tA*float(frameCount);
  loadPixels();
  float transEnd = transStart + transWidth;
  float transEnd2 = transStart2 + transWidth2;
  for ( int x = 0; x < width/2; x++ ) {
    for ( int y = 0; y<=x && y<height/2; y++ ) {
      if( y <= x*slope+1 ) {
        float x2 = px[x+y*width/2];
        float y2 = py[x+y*width/2];
  
        float f = noise( ag*af*(30*xRes + x2), ag*af*(30*yRes + y2), tf*t ) * pf[x+y*width/2] ;
        color c;
        if ( f > transStart && f < transEnd || f > transStart2 && f < transEnd2 ) {
          c = lerpColor( P[x+y*width/2], color(255, 255, 255), alpha );
          pa[x+y*width/2] = 0;
        } else if ( f >= transStart+transWidth && f < transStart2 ) {
          float h = (frameCount*tc*tA + centerH + widthH*(-0.5+noise( ag*ah*(0*xRes + x2), ag*ah*y2, th*t ) ) )%1;
          float b = lerp( minB, maxB, (f-transEnd)/(1-transEnd));
          c = lerpColor( P[x+y*width/2], hsbColor(h*360, 1, b), alpha );
          pa[x+y*width/2] = 0;
        } else {
          if ( pa[x+y*width/2] < 20 ) {
            c = lerpColor( P[x+y*width/2], color(0, 0, 0), alpha );
            pa[x+y*width/2]++;
          } else { 
            c = color( 0, 0, 0 );
          }
        }
        P[x+y*width/2] = c;
      }
    }
  }
  for ( int x = 0; x < width/2; x++ ) {
    for ( int y = 0; y<=x && y<height/2; y++ ) {
      int x2 = round( px[x+y*width/2] );
      int y2 = round( py[x+y*width/2] );
      color c = P[x2+y2*width/2];
      pixels[ (width/2+x) + (height/2+y)*width ] = c;
      pixels[ (width/2+x) + (height/2-y)*width ] = c;
      pixels[ (width/2-x) + (height/2+y)*width ] = c;
      pixels[ (width/2-x) + (height/2-y)*width ] = c;
      if ( x < height/2 ) {
        pixels[ (width/2+y) + (height/2+x)*width ] = c;
        pixels[ (width/2+y) + (height/2-x)*width ] = c;
        pixels[ (width/2-y) + (height/2+x)*width ] = c;
        pixels[ (width/2-y) + (height/2-x)*width ] = c;
      }
    }
  }
  updatePixels();

  // clock stuff
  float secAng = TWO_PI * float(second())/60;
  float minAng = TWO_PI * (float(minute())+float(second())/60)/60;
  float hourAng = TWO_PI * (float(hour()%12)+float(minute())/60)/12;
  translate( 0.5*xRes, 0.5*yRes );
  stroke( 255, 255, 255, 128 );
  fill(0);
  float h = (frameCount*tc*tA + centerH + widthH*(-0.5+noise( 0.1*th*t ) ) )%1;
  color c = hsbColor( h*360, 0.5, 0.5) ;
  
  strokeWeight(1.0);
  float cr = 4;
  fill( red(c), green(c), blue(c), 196 );
  
  pushMatrix();
  rotate( PI+minAng );
  rect( -0.5*minuteWidth*yRes, -backEnd*yRes, minuteWidth*yRes, minuteLength*yRes, cr, cr, cr, cr );
  popMatrix();
  h = (frameCount*tc*tA + centerH + widthH*(-0.5+noise( -0.1*th*t ) ) )%1;
  c = hsbColor( h*360, 0.5, 0.5) ;
  fill( red(c), green(c), blue(c), 196 );
  pushMatrix();
  rotate( PI+hourAng );
  rect( -0.5*hourWidth*yRes, -backEnd*yRes, hourWidth*yRes, hourLength*yRes, cr, cr, cr, cr );
  popMatrix();
  noStroke();


  if ( frameCount%50 == 0 ) {
    println(frameRate);
  }
}

void mouseClicked() { 
  exit();
}

void mouseMoved() {
}
void mouseDragged() {
}

color hsbColor( float h, float s, float b ) {
  float c = b*s;
  float x = c*( 1 - abs( (h/60) % 2 - 1 ) );
  float m = b - c;
  float rp = 0;
  float gp = 0;
  float bp = 0;
  if ( 0 <= h && h < 60 ) {
    rp = c;  
    gp = x;  
    bp = 0;
  }
  if ( 60 <= h && h < 120 ) {
    rp = x;  
    gp = c;  
    bp = 0;
  }
  if ( 120 <= h && h < 180 ) {
    rp = 0;  
    gp = c;  
    bp = x;
  }
  if ( 180 <= h && h < 240 ) {
    rp = 0;  
    gp = x;  
    bp = c;
  }
  if ( 240 <= h && h < 300 ) {
    rp = x;  
    gp = 0;  
    bp = c;
  }
  if ( 300 <= h && h < 360 ) {
    rp = c;  
    gp = 0;  
    bp = x;
  }
  return color( (rp+m)*255, (gp+m)*255, (bp+m)*255 );
}