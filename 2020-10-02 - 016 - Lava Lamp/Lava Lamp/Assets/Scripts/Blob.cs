using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Blob : MonoBehaviour
{
    public float gravity = 0.1f;
    public float maxYSpeed = 1f;

    public float heatSourceY = -0.5f;
    public float heatSourceIntensity = 1;
    public float passiveCoolingRate = 0.5f;
    public float temperatureForce = 0.01f;

    public float maxTemperature = 100f;
    public float temperatureMinScale = 0.1f;
    public float temperatureMaxScale = 0.5f;

    public float temperature = 0f;
    public Vector3 velocity = Vector3.zero;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    private void FixedUpdate()
    {
        // Apply heating
        float distToHeatSource = Mathf.Abs(transform.localPosition.y - heatSourceY);
        float heatInfluence = (1f-distToHeatSource) * (1f-distToHeatSource) * heatSourceIntensity;
        temperature += (heatInfluence - passiveCoolingRate) * Time.fixedDeltaTime;
        temperature = Mathf.Clamp(temperature, 0f, maxTemperature);

        // Temperature and gravity affect our Y speed
        float ySpeedDelta = (temperature*temperatureForce - gravity) * Time.fixedDeltaTime;
        float ySpeed = Mathf.Clamp(velocity.y + ySpeedDelta, -maxYSpeed, maxYSpeed);
        velocity = new Vector3(velocity.x, ySpeed, velocity.z);

        // Temperature affects scale
        float scale = temperatureMinScale + (temperature/maxTemperature)*(temperatureMaxScale-temperatureMinScale);
        transform.localScale = Vector3.one * scale;

        // Move according to current velocity
        transform.localPosition += (velocity * Time.fixedDeltaTime);

        // Stop if we hit the bottom
        if (transform.localPosition.y < heatSourceY)
        {
            transform.localPosition = new Vector3(transform.localPosition.x, heatSourceY, transform.localPosition.z);

            // Cancel out our downward speed
            if (velocity.y < 0f)
            {
                velocity = new Vector3(velocity.x, 0f, velocity.z);
            }
        }

        // Stop if we hit the top
        if (transform.localPosition.y > -heatSourceY)
        {
            transform.localPosition = new Vector3(transform.localPosition.x, -heatSourceY, transform.localPosition.z);

            // Cancel out our upward speed
            if (velocity.y > 0f)
            {
                velocity = new Vector3(velocity.x, 0f, velocity.z);
            }
        }
    }
}
