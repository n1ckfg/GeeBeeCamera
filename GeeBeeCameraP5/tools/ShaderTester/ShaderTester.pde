// https://petapixel.com/2022/05/05/a-review-of-the-nintendo-game-boy-camera-24-years-later/

import processing.video.*;

Capture video;
int captureIndex = 0;
PShader ps;
int camW = 640;
int camH = 480;
int camFps = 30;

void setup() {
  size(1280, 960, P2D);
  noSmooth();
 
  ps = loadShader("denoise.glsl");

  if (System.getProperty("os.name").toLowerCase().startsWith("mac")) {
    video = new Capture(this, camW, camH, "pipeline: autovideosrc");
  } else {
    video = new Capture(this, camW, camH, Capture.list()[captureIndex], camFps);
  }
  video.start(); 
}

void draw() {
  background(0);
  float time = (float) millis() / 1000.0;
  
  image(video, 0, 0, width, height);
  ps.set("tex0", video);
  ps.set("iResolution", float(width), float(height));
  filter(ps);

    
  surface.setTitle("" + frameRate);
}

void captureEvent(Capture c) {
  c.read();
}
