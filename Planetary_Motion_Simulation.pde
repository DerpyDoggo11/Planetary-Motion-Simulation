import peasy.*;

PeasyCam camera;
PImage sunTexture, backgroundTexture;
PImage mercuryTexture, venusTexture, earthTexture, marsTexture;
PImage jupiterTexture, saturnTexture, uranusTexture, neptuneTexture;

float G = 6.67430e-11;
float sunMass = 1.989e30;
float timeStep = 3600 * 100; // 1 hour in seconds

float scaleFactor = 1000;
float translationFactor = 1e8;
float rotationSpeedFactor = 1e4; // visual speed
float visualSpeedFactor = 1;

Planet mercury, venus, earth, mars, jupiter, saturn, uranus, neptune;

float visViva(float a, float r) {
  return sqrt(G * sunMass * (2 / r - 1 / a));
}

class Planet {
  PImage texture;
  PVector pos, vel;
  float radius;
  ArrayList<PVector> trail = new ArrayList<PVector>();
  float axialTilt; // degrees
  float rotationPeriod; // seconds
  float rotationAngle = 0;

  Planet(PImage texture, float a, float e, float radiusKM, float tiltDeg, float siderealDaySec) {
    float r = a * (1 - e);
    float v = visViva(a, r);
    this.texture = texture;
    this.pos = new PVector(r, 0, 0);
    this.vel = new PVector(0, v, 0);
    this.radius = radiusKM;
    this.axialTilt = tiltDeg;
    this.rotationPeriod = siderealDaySec;
  }

  void update() {
    PVector r = PVector.sub(pos, new PVector(0,0,0));
    float distance = r.mag();
    float accelMag = -G * sunMass / (distance * distance);
    PVector accel = r.copy().normalize().mult(accelMag);
    vel.add(PVector.mult(accel, timeStep));
    pos.add(PVector.mult(vel, timeStep));
    trail.add(pos.copy());
    rotationAngle += TWO_PI * timeStep / rotationPeriod * visualSpeedFactor;
  }

  void draw() {
    drawSphere(pos.x, pos.y, pos.z, texture, radius, axialTilt, rotationAngle);
    stroke(0, 150, 255);
    noFill();
    beginShape();
    for (PVector p : trail) {
      vertex(p.x / translationFactor, p.y / translationFactor, p.z / translationFactor);
    }
    endShape();
  }
  
  void drawInfo() {
    fill(255);
    textSize(10);
    PVector screenPos = new PVector(pos.x / translationFactor, pos.y / translationFactor, pos.z / translationFactor);
    pushMatrix();
    translate(screenPos.x, screenPos.y, screenPos.z);
    textAlign(LEFT);
    text(
      "Rot. Period: " + nf(rotationPeriod / 3600.0, 1, 2) + " hrs\n" +
      "Orb. Speed: " + nf(vel.mag() / 1000.0, 1, 2) + " km/s\n" +
      "Dist. from Sun: " + nf(pos.mag() / 1e9, 1, 0) + " million km",
      10, 0
    );
    popMatrix();
  }

}

void setup() {
  size(640, 360, P3D);
  sunTexture = loadImage("sunTexture.jpg");
  backgroundTexture = loadImage("stars.jpg");

  mercuryTexture = loadImage("mercuryTexture.jpg");
  venusTexture   = loadImage("venusTexture.jpg");
  earthTexture   = loadImage("earthTexture.jpg");
  marsTexture    = loadImage("marsTexture.jpg");
  jupiterTexture = loadImage("jupiterTexture.jpg");
  saturnTexture  = loadImage("saturnTexture.jpg");
  uranusTexture  = loadImage("uranusTexture.jpg");
  neptuneTexture = loadImage("neptuneTexture.jpg");

  float fov = PI / 3.0;
  float cameraZ = (height / 2.0) / tan(fov / 2.0);
  perspective(fov, float(width)/float(height), cameraZ / 10.0, cameraZ * 10000.0);
  camera = new PeasyCam(this, 0, 0, 0, 200);

  mercury = new Planet(mercuryTexture, 57.91e9, 0.2056, 2440, 0.03, 5070000);
  venus   = new Planet(venusTexture, 108.2e9, 0.0067, 3760, 177.4, -20997000);
  earth   = new Planet(earthTexture, 149.6e9, 0.0167, 6370, 23.44, 86164);
  mars    = new Planet(marsTexture, 227.9e9, 0.0934, 3390, 25.19, 88642);
  jupiter = new Planet(jupiterTexture, 778.5e9, 0.0489, 71490, 3.13, 35730);
  saturn  = new Planet(saturnTexture, 1.433e12, 0.0565, 58232, 26.73, 38362);
  uranus  = new Planet(uranusTexture, 2.877e12, 0.0457, 25560, 97.77, -62064);
  neptune = new Planet(neptuneTexture, 4.503e12, 0.0113, 24764, 28.32, 57996);

}

void draw() {
  background(0);
  drawSphere(0, 0, 0, sunTexture, 696340 / 2, 7.25, (frameCount * TWO_PI / 2192832) * 0.1);

  mercury.update(); mercury.draw(); mercury.drawInfo();
  venus.update();   venus.draw(); venus.drawInfo();
  earth.update();   earth.draw(); earth.drawInfo();
  mars.update();    mars.draw(); mars.drawInfo();
  jupiter.update(); jupiter.draw(); jupiter.drawInfo();
  saturn.update();  saturn.draw(); saturn.drawInfo();
  uranus.update();  uranus.draw(); uranus.drawInfo(); 
  neptune.update(); neptune.draw(); neptune.drawInfo();
}

void drawSphere(float x, float y, float z, PImage texture, float radiusKM, float axialTiltDeg, float rotationAngle) {
  x = x / translationFactor;
  y = y / translationFactor;
  z = z / translationFactor;
  
  noStroke();

  pushMatrix();
  translate(x, y, z);
  rotateZ(radians(axialTiltDeg));
  rotateY(rotationAngle * rotationSpeedFactor);

  textureMode(NORMAL);
  beginShape(TRIANGLE_STRIP);
  texture(texture);

  int detail = 40;
  float radius = radiusKM / scaleFactor;

  for (int i = 0; i <= detail; i++) {
    float theta1 = map(i, 0, detail, 0, PI);
    float theta2 = map(i + 1, 0, detail, 0, PI);

    for (int j = 0; j <= detail; j++) {
      float phi = map(j, 0, detail, 0, TWO_PI);

      float x1 = radius * sin(theta1) * cos(phi);
      float y1 = radius * cos(theta1);
      float z1 = radius * sin(theta1) * sin(phi);
      float u = map(j, 0, detail, 0, 1);
      float v1 = map(i, 0, detail, 0, 1);
      vertex(x1, y1, z1, u, v1);

      float x2 = radius * sin(theta2) * cos(phi);
      float y2 = radius * cos(theta2);
      float z2 = radius * sin(theta2) * sin(phi);
      float v2 = map(i + 1, 0, detail, 0, 1);
      vertex(x2, y2, z2, u, v2);
    }
  }

  endShape();
  popMatrix();
}
