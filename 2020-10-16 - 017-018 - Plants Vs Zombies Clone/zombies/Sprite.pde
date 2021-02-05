public class Sprite {
  
  PImage spritesheet;
  boolean facingLeft = false;
  int spriteFootOffset;
  
  PVector position;
  
  HashMap<String, Animation> animations = new HashMap<String, Animation>();
  String currentAnimationName;
  Animation currentAnimation;
  float secondsSinceAnimationStarted = 0;
  
  void changeAnimation(String animName) {
    currentAnimationName = animName;
    currentAnimation = animations.get(animName);
    secondsSinceAnimationStarted = 0;
  }
  
  void updateAnimation(float secondsElapsed) {
    secondsSinceAnimationStarted += secondsElapsed;
  }
  
  boolean isAnimationComplete() {
    return secondsSinceAnimationStarted >= currentAnimation.numFrames * currentAnimation.frameDurationSeconds;
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
    translate(position.x, position.y - spriteFootOffset, position.z);
    if (facingLeft) {
      rotateY(PI);
    }

    int frameStartX = animation.topLeftX + animation.frameWidth*frameIndex;
    
    tint(255);
    image(
        spritesheet,
        0, 0,                                                                           // Position
        animation.frameWidth, animation.frameHeight,                                    // Target size
        frameStartX, animation.topLeftY,                                                // Source top-left
        frameStartX + animation.frameWidth, animation.topLeftY + animation.frameHeight  // Source size  
    );

    popMatrix();
  }
}
