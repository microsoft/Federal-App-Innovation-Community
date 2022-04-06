using System;
using Microsoft.Azure.Cosmos;
using System.Threading.Tasks;
using System.Collections.Generic;
public class DAL
{
    public const string COSMOS_CONTAINER = "bike";
    public const string COSMOS_BIKE_TABLE = "bike";

    private const string COSMOS_CONNECTION_STRING = "AccountEndpoint=https://mycosmosdb521.documents.azure.com:443/;AccountKey=OjrNCTsIfF807q80dmZmxqnDHSfJKFfcu9teSVo2czGxDauprYUEJPnUEd3Rvqqt9PjGz8JY08KvqeErm4nVPg==;";
    private static Lazy<CosmosClient> m_lcdb = new Lazy<CosmosClient>(InitializeCosmosClient);
    private static CosmosClient m_cdb => m_lcdb.Value;
    private static CosmosClient InitializeCosmosClient()
    {
        return new CosmosClient(DAL.COSMOS_CONNECTION_STRING);
    }
    public static async Task CreateBikeAsync(Models.Bike Bike)
    {
        try
        {
            Container c                                                 = m_cdb.GetContainer(DAL.COSMOS_CONTAINER, DAL.COSMOS_BIKE_TABLE);
            await c.CreateItemAsync<Models.Bike>(Bike);
        }
        catch (Exception ex)
        {
        }
    }

    public static async Task SaveBikeAsync(Models.Bike Bike)
    {
        try
        {
            Container c                                                 = m_cdb.GetContainer(DAL.COSMOS_CONTAINER, DAL.COSMOS_BIKE_TABLE);
            await c.ReplaceItemAsync<Models.Bike>(Bike, Bike.ID);
        }
        catch (Exception exError)
        { }
    }

    public static async Task<Models.Bike> GetBikeByIDAsync(string ID, string Partition)
    {
        Models.Bike bkReturn                                            = null;

        try
        {
            Container c                                                 = m_cdb.GetContainer(DAL.COSMOS_CONTAINER, DAL.COSMOS_BIKE_TABLE);

            bkReturn                                                    = await c.ReadItemAsync<Models.Bike>(ID, new PartitionKey(Partition));
        }
        catch (Exception ex)
        {

        }

        return bkReturn;
    }

    public static async Task<Models.Bike[]> GetAllBikesAsync()
    {
        List<Models.Bike> abk                                           = new List<Models.Bike>();
        try
        {
            Container c                                                 = m_cdb.GetContainer(DAL.COSMOS_CONTAINER, DAL.COSMOS_BIKE_TABLE);

            var sqlQueryText                                            = "SELECT * FROM c";

            QueryDefinition queryDefinition                             = new QueryDefinition(sqlQueryText);
            FeedIterator<Models.Bike> queryResultSetIterator            = c.GetItemQueryIterator<Models.Bike>(queryDefinition);

            while (queryResultSetIterator.HasMoreResults)
            {
                FeedResponse<Models.Bike> currentResultSet              = await queryResultSetIterator.ReadNextAsync();
                foreach (Models.Bike b in currentResultSet)
                    abk.Add(b);
            }
        }
        catch (Exception ex)
        {

        }

        return abk.ToArray();
    }
}