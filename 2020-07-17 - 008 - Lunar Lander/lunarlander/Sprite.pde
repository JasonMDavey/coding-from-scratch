public class Sprite {
  
  PImage spritesheet;

  HashMap<String, Animation> animations = new HashMap<String, Animation>(); 
  Animation currentAnimation;
  float secondsSinceAnimationStarted = 0;
  
  public Sprite(PImage spritesheet) {
    this.spritesheet = spritesheet;
  }
  
  void changeAnimation(String animName) {
    currentAnimation = animations.get(animName);
    secondsSinceAnimationStarted = 0;
  }
  
  void updateAnimation(float secondsElapsed) {
    secondsSinceAnimationStarted += secondsElapsed;
  }
  
  boolean isAnimationComplete() {
    return secondsSinceAnimationStarted > currentAnimation.frameDurationSeconds * currentAnimation.numFrames; 
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
    
    int frameStartX = animation.topLeftX + animation.frameWidth*frameIndex;
    
    image(
        spritesheet,
        0, 0,                                                                           // Position
        animation.frameWidth, animation.frameHeight,                                    // Target size
        frameStartX, animation.topLeftY,                                                // Source top-left
        frameStartX + animation.frameWidth, animation.topLeftY + animation.frameHeight  // Source bottom-right  
    );
  }
}
