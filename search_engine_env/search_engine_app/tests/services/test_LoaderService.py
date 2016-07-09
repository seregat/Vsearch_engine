import unittest

from search_engine_app.services.LoaderService import LoaderService
from search_engine_app.tests.services.test_googleSearch import googleSearchTests

mockupPath = googleSearchTests.getGoogleResponseMockupFilePath()
LoaderService.setMockupMode(mockupPath)

class LoaderServiceTest(unittest.TestCase):

    def test_retrieveContentFromListOfQueries(self):
        try:
            query = ["https://docs.python.org","some search"]
            (good_reponse,wrong_responses,wrong_queries) = LoaderService.retrieveContentFromListOfQueries(query)
            #print(good_reponse)
            self.assertFalse(wrong_responses,'wrong response must be empty')
            self.assertFalse(wrong_queries,'wrong query must be empty')
            for response in good_reponse:
                data = response[LoaderService._RESPONSE_INDEX]
                print(data)
                self.assertTrue("div" in response[LoaderService._RESPONSE_INDEX],'response must contain div element:{0}'.format(response))

            if isinstance(good_reponse, Exception):
                self.assertTrue(False, "This must be response from url")
        except Exception as e:
            self.assertTrue(False,str(e))


    def test_retrieveContentFromQuery(self):
        try:

            query = "https://docs.python.org"
            actual = LoaderService._retrieveContent(query)
            self.assertTrue("div" in actual[LoaderService._RESPONSE_INDEX],self.assertTrue("div" in response[LoaderService._RESPONSE_INDEX],'response must contain div element:{0}'.format(actual)))
            #print(actual)
            if isinstance(actual,Exception):
                self.assertTrue(False,"This must be response from url")
        except Exception as e:
            self.assertTrue(False,str(e))



if __name__ == "__main__":
    unittest.main()