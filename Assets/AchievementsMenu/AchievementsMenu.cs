using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace AchievementsAPI
{
    public class AchievementsMenu : MonoBehaviour
    {
        public GameObject achievementItemPrefab;
        public Transform unlockedContentParent;
        public Transform lockedContentParent;
        public Transform tabsParent;
        public GameObject tabPrefab;
        public TextMeshProUGUI titleText;
        public void Close()
        {
        }
    }
}
