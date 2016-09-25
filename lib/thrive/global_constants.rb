module Track::GlobalConstants

  BASE_DOMAIN = "watertracker.io"  # ENV["BASE_DOMAIN"] || (Rails.env == 'development' ? "watertracker.io" : "youritrackwater.com")

  BASE_TENANT = "app"

  STEPS = ['profile', 'health', 'diet', 'movement', 'environment', 'rejuvenation', 'spirit']

  NOTIFY_TEXT = "!!! Alert! Information that you have submitted suggests that you may have a medical or behavioral condition warranting attention by a medical provider.
                It is strongly recommended that you contact your Cancer Center to discuss this and obtain follow up care, OR that you seek treatment from another health care provider of your choosing.
                This is solely related to your status as a Cancer Survivor and is intended to help maximize your healthy lifestyle and facilitate your goals in connection with the iTrack Plan.
                This Alert is confidential and will not be sent to any health care providers or disclosed to any other individual or entity, UNLESS you are using the iTrack Plan at the recommendation of, and as part of your ongoing treatment with, a Cancer Center, in which case, the information will be conveyed to the Cancer Center."

  FINAL_TEXT = "Congratulations!  You have completed the survey and are now ready to start thriving.  Next, check out your strengths assessment and go to the my plan page to choose 2 action steps and start the program."
  PROFILE_INTRO_1 = " The goal of the survey is to learn about your current lifestyle behaviors so that we can generate an iTrack Plan that matches your unique strengths and areas of need. Based on all of your answers, your iTrack Plan will present you with recommended Action Steps in five areas that are critical to optimal health: Diet, Movement, Environment, Rejuvenation and Spirit. As you take the survey, be sure to answer all of the questions as truthfully as possible so you will receive a perfectly tailored iTrack Plan to best build your wellness!"
  DEMOGRAPHICS_INTRO = "This section of the survey gathers important information about you and your cancer history. Because this information is unlikely to change, you will only have to complete this once. If anything changes, you can always update this information in your profile."
  HEALTH_INTRO = "This section of the survey helps identify areas of distress and also gives us information we need to filter out any recommendations (Action Steps) that may not be safe or appropriate for you. You will need to answer every question."
  HEALTH_INTRO_LIKERT = "Thinking about how you have felt on most days over the past week, including today, please rate yourself on the following questions using a scale from 1 to 5. Five (5) is the best, or highest, and one (1) is the worst, or lowest:"
  SURVEY_FOOTER_TEXT = "If you are participating in the iTrack Plan as a Patient of a Cancer Center, you recognize and agree that all information you submit may be disclosed to the Cancer Center."

  ADMINS = ['aaron@missionhope.com','jason@missionhope.com','britt@missionhope.com','lise@missionhope.com','karolyn@missionhope.com','mandisa@missionhope.com']

  AGE_RANGES =
    ["under 18",
     "19-30",
     "31-49",
     "50-65",
     "over 65"]

  GENDERS =
    ["female",
     "male",
     "other"]

end
