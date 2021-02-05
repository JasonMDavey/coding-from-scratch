using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DraggableComponent : MonoBehaviour
{
    public float maxRotationOffset = 20f;
    public float rotationOffsetRate = 0.1f;
    public float rotationSettleRate = 5f;

    private bool beingDragged = false;
    private Vector3 dragStartMyPos, dragStartMousePos;

    private Vector3 rotationOffset;

    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        HandleDrag();

        // Slowly decay rotation offset, so card settles back into position
        if (rotationOffset.y > 0f)
        {
            rotationOffset.y -= Mathf.Min(rotationOffset.y, rotationSettleRate * Time.deltaTime);
        }
        else
        {
            rotationOffset.y += Mathf.Min(Mathf.Abs(rotationOffset.y), rotationSettleRate * Time.deltaTime);
        }

        if (rotationOffset.x > 0f)
        {
            rotationOffset.x -= Mathf.Min(rotationOffset.x, rotationSettleRate * Time.deltaTime);
        }
        else
        {
            rotationOffset.x += Mathf.Min(Mathf.Abs(rotationOffset.x), rotationSettleRate * Time.deltaTime);
        }

        transform.localEulerAngles = rotationOffset;
    }

    void HandleDrag()
    {
        if (beingDragged)
        {
            if (Input.GetMouseButton(0))
            {
                // Continue dragging - calculate the drag offset, and move ourself relative to that
                Vector3 oldPosition = transform.position;

                Vector3 dragMouseOffset = Camera.main.ScreenPointToRay(Input.mousePosition).origin - dragStartMousePos;
                transform.position = dragStartMyPos + dragMouseOffset;

                // Rotate in line with movement
                Vector3 movedAmount = transform.position - oldPosition;
                rotationOffset.x = Mathf.Clamp(rotationOffset.x + (movedAmount.y*Time.deltaTime*rotationOffsetRate), -maxRotationOffset, maxRotationOffset);
                rotationOffset.y = Mathf.Clamp(rotationOffset.y - (movedAmount.x*Time.deltaTime*rotationOffsetRate), -maxRotationOffset, maxRotationOffset);
            }
            else
            {
                // Mouse was released while dragging
                beingDragged = false;
            }
        }
        else
        {
            // Potentially pick up the card
            if (!Input.GetMouseButtonDown(0)) return;

            // Raycast to see if we've been clicked
            Ray mouseRay = Camera.main.ScreenPointToRay(Input.mousePosition);
            RaycastHit rayHit;
            if (!Physics.Raycast(mouseRay, out rayHit)) return;

            // Check to see if the ray hit us, and not some other object
            if (rayHit.collider.gameObject != gameObject) return;

            beingDragged = true;
            dragStartMousePos = mouseRay.origin;
            dragStartMyPos = transform.position;
        }
    }
}
