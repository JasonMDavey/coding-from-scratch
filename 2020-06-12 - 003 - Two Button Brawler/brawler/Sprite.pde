public abstract class Sprite {
  
  PImage sprite;
  boolean facingLeft = false;
  int spriteFootOffset;
  
  float xPosition;
  
  HashMap<String, Animation> animations = new HashMap<String, Animation>(); 
  Animation currentAnimation;
  float secondsSinceAnimationStarted = 0;
  
  void changeAnimation(String animName) {
    currentAnimation = animations.get(animName);
    secondsSinceAnimationStarted = 0;
  }
  
  void updateAnimation(float secondsElapsed) {
    secondsSinceAnimationStarted += secondsElapsed;
  }
  
  void draw() {
    int currentFrameIndex = (int)(secondsSinceAnimationStarted / currentAnimation.frameDurationSeconds);
    if (currentAnimation.looping) {
      currentFrameIndex = currentFrameIndex % currentAnimation.numFrames;
    }
    else if (currentFrameIndex >= currentAnimation.numFrames) {
      currentFrameIndex = currentAnimation.numFrames - 1;
    }
    
    drawAnimationFrame(currentAnimation, currentFrameIndex);
  }
  
  void drawAnimationFrame(Animation animation, int frameIndex) {
    imageMode(CENTER);
    pushMatrix();
    translate(width/2 + xPosition, FLOOR_Y - spriteFootOffset);
    if (facingLeft) {
      rotateY(PI);
    }
    
    //image(sprite, targetX, targetY, targetWidth, targetHeight, startX, startY, endX, endY);
    
    int frameStartX = animation.topLeftX + animation.frameWidth*frameIndex;
    
    image(
        sprite,
        0, 0,                                                                           // Position
        animation.frameWidth, animation.frameHeight,                                    // Target size
        frameStartX, animation.topLeftY,                                                // Source top-left
        frameStartX + animation.frameWidth, animation.topLeftY + animation.frameHeight  // Source size  
    );

    popMatrix();
  }
}
