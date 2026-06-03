using AchievementsAPI;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class scrip : MonoBehaviour
{

    public AchievementsMenuItem AchievementsMenuItem;
    
    public void Unlock()
    {
        AchievementsMenuItem.iconImage = null;
        AchievementsMenuItem.nameText.SetText("Achievement Obtained!");
        AchievementsMenuItem.descriptionText.SetText("sigma shi");
    }
    public void Progress()
    {
        
    }
}
