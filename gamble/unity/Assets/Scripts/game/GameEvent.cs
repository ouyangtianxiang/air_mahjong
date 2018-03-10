using UnityEngine;
using System.Collections;
using System.Security.Policy;
using UnityEngine.EventSystems;
using UnityEngine.Events;
using System;
using System.Diagnostics;

namespace Game
{
    public class GameEvent : UnityEngine.EventSystems.EventTrigger
    {
        public override void OnPointerClick(PointerEventData eventData)
        {
            onClick.Call(eventData, gameObject);
        }

        public override void OnPointerDown(PointerEventData eventData)
        {
            onDown.Call(eventData, gameObject);
        }

        public override void OnPointerUp(PointerEventData eventData)
        {
            onUp.Call(eventData, gameObject);
        }

        public override void OnPointerEnter(PointerEventData eventData)
        {
            onEnter.Call(eventData, gameObject);
        }

        public override void OnPointerExit(PointerEventData eventData)
        {
            onExit.Call(eventData, gameObject);
        }

        public override void OnBeginDrag(PointerEventData eventData)
        {
            onBeginDrag.Call(eventData, gameObject);
        }

        public override void OnEndDrag(PointerEventData eventData)
        {
            onEndDrag.Call(eventData, gameObject);
        }

        public override void OnMove(AxisEventData eventData)
        {
            onMove.Call(eventData, gameObject);
        }

        public override void OnDrag(PointerEventData eventData)
        {
            onDrag.Call(eventData, gameObject);
        }

        public override void OnDrop(PointerEventData eventData)
        {
            onDrop.Call(eventData, gameObject);
        }

        public GameEventType<PointerEventData> onClick = new GameEventType<PointerEventData>();
        public GameEventType<PointerEventData> onDown = new GameEventType<PointerEventData>();
        public GameEventType<PointerEventData> onUp = new GameEventType<PointerEventData>();
        public GameEventType<PointerEventData> onEnter = new GameEventType<PointerEventData>();
        public GameEventType<PointerEventData> onExit = new GameEventType<PointerEventData>();
        public GameEventType<PointerEventData> onSelect = new GameEventType<PointerEventData>();
        public GameEventType<PointerEventData> onUpdateSelect = new GameEventType<PointerEventData>();
        public GameEventType<PointerEventData> onBeginDrag = new GameEventType<PointerEventData>();
        public GameEventType<PointerEventData> onEndDrag = new GameEventType<PointerEventData>();
        public GameEventType<PointerEventData> onDrag = new GameEventType<PointerEventData>();
        public GameEventType<PointerEventData> onDrop = new GameEventType<PointerEventData>();
        public GameEventType<AxisEventData> onMove = new GameEventType<AxisEventData>();

        [Serializable]
        public class GameEventType<T>
        {
            public delegate void GameEventCall(T eventData, GameObject go);

            GameEventCall call;

            public void AddListener(GameEventCall call)
            {
                this.call += call;
            }

            public void RemoveListener(GameEventCall call)
            {
                this.call -= call;
                DelegateFactory.RemoveDelegate(call);
            }

            public void Call(T eventData, GameObject go)
            {
                if (call != null)
                {
                    call(eventData, go);
                }
            }
        }
    }
}