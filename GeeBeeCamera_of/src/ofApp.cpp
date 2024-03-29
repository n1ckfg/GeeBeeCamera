#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup() {
    settings.loadFile("settings.xml");

    std::cout << endl;
#ifdef TARGET_OPENGLES
    if (ofIsGLProgrammableRenderer()) {
	shader.load("vhsc_es3");
	std::cout << "* * * Using OpenGL ES3 * * *" << endl;
    } else {
	shader.load("vhsc_es2");
	std::cout << "* * * Using OpenGL ES2 * * *" << endl;
    }
#else
    if (ofIsGLProgrammableRenderer()) {
        shader.load("vhsc_gl3");
	std::cout << "* * * Using OpenGL 3 * * *" << endl;
    } else {
        shader.load("vhsc_gl2");
	std::cout << "* * * Using OpenGL 2 * * *" << endl;
    }
#endif
std::cout << endl;

    camWidth = 640;  // try to grab at this size.
    camHeight = 480;
    camFps = 30;

    //get back a list of devices.
    vector<ofVideoDevice> devices = vidGrabber.listDevices();

    for (size_t i = 0; i < devices.size(); i++) {
        if (devices[i].bAvailable) {
            //log the device
            ofLogNotice() << devices[i].id << ": " << devices[i].deviceName;
        } else {
            //log the device and note it as unavailable
            ofLogNotice() << devices[i].id << ": " << devices[i].deviceName << " - unavailable ";
        }
    }

    deviceIndex = settings.getValue("settings:device_index", 0);

    vidGrabber.setDeviceID(deviceIndex);
    vidGrabber.setDesiredFrameRate(camFps);
    vidGrabber.initGrabber(camWidth, camHeight);

    videoInverted.allocate(vidGrabber.getWidth(), vidGrabber.getHeight(), OF_PIXELS_RGB);
    videoTexture.allocate(videoInverted);
    ofSetVerticalSync(true);

    plane.set(ofGetWidth(), ofGetHeight(), 3, 3, OF_PRIMITIVE_TRIANGLES);
    plane.mapTexCoordsFromTexture(vidGrabber.getTextureReference());
}


//--------------------------------------------------------------
void ofApp::update() {
    ofBackground(100, 100, 100);
    vidGrabber.update();

    if (vidGrabber.isFrameNew()) {
        //
    }
}

//--------------------------------------------------------------
void ofApp::draw() {
    vidGrabber.getTextureReference().bind();
    shader.begin();
    ofPushMatrix();
    ofTranslate(ofGetWidth() / 2, ofGetHeight() / 2);
    ofScale(1.0, -1.0, 1.0);
    plane.draw();
    ofPopMatrix();
    shader.end();
    vidGrabber.getTextureReference().unbind();
}


//--------------------------------------------------------------
void ofApp::keyPressed(int key) {
    // in fullscreen mode, on a pc at least, the 
    // first time video settings the come up
    // they come up *under* the fullscreen window
    // use alt-tab to navigate to the settings
    // window. we are working on a fix for this...

    // Video settings no longer works in 10.7
    // You'll need to compile with the 10.6 SDK for this
    // For Xcode 4.4 and greater, see this forum post on instructions on installing the SDK
    // http://forum.openframeworks.cc/index.php?topic=10343
    if (key == 's' || key == 'S') {
        vidGrabber.videoSettings();
    }
}

//--------------------------------------------------------------
void ofApp::keyReleased(int key) {
}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y) {
}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button) {
}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button) {
}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button) {
}

//--------------------------------------------------------------
void ofApp::mouseEntered(int x, int y) {
}

//--------------------------------------------------------------
void ofApp::mouseExited(int x, int y) {
}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h) {
}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg) {
}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo) {
}
